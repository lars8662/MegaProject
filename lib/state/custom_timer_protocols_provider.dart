import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_timer_protocol.dart';

final customTimerProtocolsProvider = NotifierProvider<CustomTimerProtocolsNotifier, List<CustomTimerProtocol>>(
  CustomTimerProtocolsNotifier.new,
);

class CustomTimerProtocolsNotifier extends Notifier<List<CustomTimerProtocol>> {
  static const _storageKey = 'custom_timer_protocols_v1';

  @override
  List<CustomTimerProtocol> build() {
    _loadProtocols();
    return const [];
  }

  Future<void> addProtocol(CustomTimerProtocol protocol) async {
    state = [protocol, ...state];
    await _saveProtocols();
  }

  Future<void> _loadProtocols() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedProtocols = preferences.getStringList(_storageKey) ?? const [];

    final protocols = <CustomTimerProtocol>[];

    for (final encodedProtocol in encodedProtocols) {
      try {
        final decoded = jsonDecode(encodedProtocol) as Map<String, dynamic>;
        protocols.add(CustomTimerProtocol.fromJson(decoded));
      } catch (_) {
        // Skip corrupted local entries instead of blocking app startup.
      }
    }

    if (protocols.isNotEmpty) {
      state = protocols;
    }
  }

  Future<void> _saveProtocols() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedProtocols = state.map((protocol) => jsonEncode(protocol.toJson())).toList(growable: false);

    await preferences.setStringList(_storageKey, encodedProtocols);
  }
}
