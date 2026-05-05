import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_session.dart';

final trainingSessionsProvider = NotifierProvider<TrainingSessionsNotifier, List<TrainingSession>>(
  TrainingSessionsNotifier.new,
);

class TrainingSessionsNotifier extends Notifier<List<TrainingSession>> {
  static const _storageKey = 'training_sessions_v1';

  @override
  List<TrainingSession> build() {
    _loadSessions();
    return const [];
  }

  Future<void> addSession(TrainingSession session) async {
    state = [session, ...state];
    await _saveSessions();
  }

  Future<void> updateSession(TrainingSession updatedSession) async {
    state = state
        .map((session) => session.id == updatedSession.id ? updatedSession : session)
        .toList(growable: false);
    await _saveSessions();
  }

  Future<void> deleteSession(String id) async {
    state = state.where((session) => session.id != id).toList(growable: false);
    await _saveSessions();
  }

  TrainingSession? findById(String id) {
    for (final session in state) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  Future<void> _loadSessions() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedSessions = preferences.getStringList(_storageKey) ?? const [];

    final sessions = <TrainingSession>[];

    for (final encodedSession in encodedSessions) {
      try {
        final decoded = jsonDecode(encodedSession) as Map<String, dynamic>;
        sessions.add(TrainingSession.fromJson(decoded));
      } catch (_) {
        // Skip corrupted local entries instead of blocking app startup.
      }
    }

    if (sessions.isNotEmpty) {
      state = sessions;
    }
  }

  Future<void> _saveSessions() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedSessions = state.map((session) => jsonEncode(session.toJson())).toList(growable: false);

    await preferences.setStringList(_storageKey, encodedSessions);
  }
}
