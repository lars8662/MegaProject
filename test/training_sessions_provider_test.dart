import 'dart:convert';

import 'package:climbing_diary/models/training_session.dart';
import 'package:climbing_diary/state/training_sessions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'training_sessions_v1';

void main() {
  group('TrainingSessionsNotifier persistence', () {
    test('adding a TrainingSession updates provider state', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _letInitialLoadComplete(container);

      final session = _session(id: 'session-state');

      await container.read(trainingSessionsProvider.notifier).addSession(session);

      expect(container.read(trainingSessionsProvider), [session]);
    });

    test('adding a TrainingSession persists data to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _letInitialLoadComplete(container);

      final session = _session(
        id: 'session-persisted',
        type: 'Фингерборд',
        date: DateTime.utc(2025, 4, 10, 18, 45),
        exerciseName: 'Висы 7/3',
        source: 'timer',
        rounds: 6,
        repsPerRound: 5,
        extraWeightKg: '12.5',
        workSeconds: 7,
        restSeconds: 3,
        preparationSeconds: 20,
      );

      await container.read(trainingSessionsProvider.notifier).addSession(session);

      final preferences = await SharedPreferences.getInstance();
      final savedSessions = preferences.getStringList(_storageKey);

      expect(savedSessions, isNotNull);
      expect(savedSessions, hasLength(1));
      expect(jsonDecode(savedSessions!.single), session.toJson());
    });

    test('existing SharedPreferences data under the storage key is loaded', () async {
      final savedSession = _session(id: 'session-loaded');
      SharedPreferences.setMockInitialValues(<String, Object>{
        _storageKey: <String>[jsonEncode(savedSession.toJson())],
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await _waitForSessionCount(container, 1);

      final loadedSession = container.read(trainingSessionsProvider).single;
      _expectSameSession(loadedSession, savedSession);
    });

    test('storage uses the existing key and JSON string-list format', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await _letInitialLoadComplete(container);

      final olderSession = _session(id: 'older-session', date: DateTime.utc(2025, 1, 1));
      final newerSession = _session(id: 'newer-session', date: DateTime.utc(2025, 1, 2));

      await container.read(trainingSessionsProvider.notifier).addSession(olderSession);
      await container.read(trainingSessionsProvider.notifier).addSession(newerSession);

      final preferences = await SharedPreferences.getInstance();

      expect(preferences.getKeys(), contains(_storageKey));
      final savedSessions = preferences.getStringList(_storageKey);
      expect(savedSessions, hasLength(2));
      expect(savedSessions, everyElement(isA<String>()));
      expect(jsonDecode(savedSessions![0]), newerSession.toJson());
      expect(jsonDecode(savedSessions[1]), olderSession.toJson());
    });

    test('invalid saved JSON entries are skipped without crashing provider load', () async {
      final validSession = _session(id: 'valid-session');
      SharedPreferences.setMockInitialValues(<String, Object>{
        _storageKey: <String>[
          '{invalid-json',
          jsonEncode(validSession.toJson()),
          jsonEncode(<String>['not', 'a', 'session', 'map']),
        ],
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(() => container.read(trainingSessionsProvider), returnsNormally);
      await _waitForSessionCount(container, 1);

      final loadedSession = container.read(trainingSessionsProvider).single;
      _expectSameSession(loadedSession, validSession);
    });
  });
}

TrainingSession _session({
  required String id,
  String type = 'Трудность',
  DateTime? date,
  int durationMinutes = 90,
  String location = 'Скалодром Север',
  int intensity = 8,
  String effort = 'Тяжело',
  String notes = 'Разминка, трассы 6b-7a, заминка.',
  String? exerciseName,
  String? source,
  int? rounds,
  int? repsPerRound,
  String? extraWeightKg,
  int? workSeconds,
  int? restSeconds,
  int? preparationSeconds,
}) {
  return TrainingSession(
    id: id,
    type: type,
    date: date ?? DateTime.utc(2025, 3, 14, 9, 26),
    durationMinutes: durationMinutes,
    location: location,
    intensity: intensity,
    effort: effort,
    notes: notes,
    exerciseName: exerciseName,
    source: source,
    rounds: rounds,
    repsPerRound: repsPerRound,
    extraWeightKg: extraWeightKg,
    workSeconds: workSeconds,
    restSeconds: restSeconds,
    preparationSeconds: preparationSeconds,
  );
}

Future<void> _letInitialLoadComplete(ProviderContainer container) async {
  container.read(trainingSessionsProvider);
  await pumpEventQueue();
}

Future<void> _waitForSessionCount(ProviderContainer container, int count) async {
  container.read(trainingSessionsProvider);

  for (var attempt = 0; attempt < 10; attempt += 1) {
    await pumpEventQueue();
    if (container.read(trainingSessionsProvider).length == count) {
      return;
    }
  }

  final actualCount = container.read(trainingSessionsProvider).length;
  fail('Expected $count training session(s), found $actualCount.');
}

void _expectSameSession(TrainingSession actual, TrainingSession expected) {
  expect(actual.id, expected.id);
  expect(actual.type, expected.type);
  expect(actual.date, expected.date);
  expect(actual.durationMinutes, expected.durationMinutes);
  expect(actual.location, expected.location);
  expect(actual.intensity, expected.intensity);
  expect(actual.effort, expected.effort);
  expect(actual.notes, expected.notes);
  expect(actual.exerciseName, expected.exerciseName);
  expect(actual.source, expected.source);
  expect(actual.rounds, expected.rounds);
  expect(actual.repsPerRound, expected.repsPerRound);
  expect(actual.extraWeightKg, expected.extraWeightKg);
  expect(actual.workSeconds, expected.workSeconds);
  expect(actual.restSeconds, expected.restSeconds);
  expect(actual.preparationSeconds, expected.preparationSeconds);
}
