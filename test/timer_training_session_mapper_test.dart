import 'package:climbing_diary/models/timer_training_session_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('trainingSessionFromFinishedTimer', () {
    test('built-in Repeaters-style timer preserves current built-in behavior', () {
      final session = trainingSessionFromFinishedTimer(
        id: 'repeaters-id',
        date: DateTime.utc(2025, 1, 2, 3, 4),
        timerTitle: 'Repeaters 7/3',
        isCustom: false,
        totalSeconds: 65,
        workSeconds: 7,
        restSeconds: 3,
        rounds: 6,
        preparationSeconds: 5,
        repsPerRound: 5,
        extraWeightKg: '10',
      );

      expect(session.type, 'Фингерборд');
      expect(session.intensity, 7);
      expect(session.location, 'Таймер');
      expect(
        session.notes,
        'Завершён таймер: Repeaters 7/3. Работа: 00:07, отдых: 00:03, раунды: 6.',
      );
      expect(session.source, isNull);
      expect(session.exerciseName, isNull);
      expect(session.rounds, isNull);
      expect(session.repsPerRound, isNull);
      expect(session.extraWeightKg, isNull);
      expect(session.workSeconds, isNull);
      expect(session.restSeconds, isNull);
      expect(session.preparationSeconds, isNull);
      expect(session.isTimerSession, isFalse);
    });

    test('built-in ARC timer preserves current ARC behavior', () {
      final session = trainingSessionFromFinishedTimer(
        id: 'arc-id',
        date: DateTime.utc(2025, 1, 2, 3, 4),
        timerTitle: 'ARC / лёгкий объём',
        isCustom: false,
        totalSeconds: 1925,
        workSeconds: 600,
        restSeconds: 120,
        rounds: 3,
        preparationSeconds: 5,
      );

      expect(session.type, 'Трудность');
      expect(session.intensity, 4);
      expect(session.location, 'Таймер');
      expect(
        session.notes,
        'Завершён таймер: ARC / лёгкий объём. Работа: 10:00, отдых: 02:00, раунды: 3.',
      );
      expect(session.source, isNull);
      expect(session.exerciseName, isNull);
      expect(session.rounds, isNull);
      expect(session.workSeconds, isNull);
      expect(session.restSeconds, isNull);
      expect(session.preparationSeconds, isNull);
    });

    test('built-in Max Hang preserves current intensity behavior', () {
      final session = trainingSessionFromFinishedTimer(
        id: 'max-hang-id',
        date: DateTime.utc(2025, 1, 2, 3, 4),
        timerTitle: 'Max Hang',
        isCustom: false,
        totalSeconds: 775,
        workSeconds: 10,
        restSeconds: 180,
        rounds: 5,
        preparationSeconds: 5,
      );

      expect(session.type, 'Фингерборд');
      expect(session.intensity, 8);
      expect(session.location, 'Таймер');
      expect(session.source, isNull);
      expect(session.exerciseName, isNull);
      expect(session.rounds, isNull);
      expect(session.workSeconds, isNull);
      expect(session.restSeconds, isNull);
      expect(session.preparationSeconds, isNull);
    });

    test('custom timer preserves current custom timer behavior', () {
      final session = trainingSessionFromFinishedTimer(
        id: 'custom-id',
        date: DateTime.utc(2025, 1, 2, 3, 4),
        timerTitle: 'Weighted repeaters',
        isCustom: true,
        totalSeconds: 88,
        workSeconds: 8,
        restSeconds: 4,
        rounds: 8,
        preparationSeconds: 5,
        repsPerRound: 6,
        extraWeightKg: '12.5',
      );

      expect(session.type, 'ОФП');
      expect(session.intensity, 7);
      expect(session.location, '');
      expect(session.effort, 'Норма');
      expect(session.notes, '');
      expect(session.exerciseName, 'Weighted repeaters');
      expect(session.source, 'timer');
      expect(session.rounds, 8);
      expect(session.repsPerRound, 6);
      expect(session.extraWeightKg, '12.5');
      expect(session.workSeconds, 8);
      expect(session.restSeconds, 4);
      expect(session.preparationSeconds, 5);
      expect(session.isTimerSession, isTrue);
    });

    test('fixed id and date are used exactly by the returned TrainingSession', () {
      final date = DateTime.utc(2025, 6, 7, 8, 9, 10);
      final session = trainingSessionFromFinishedTimer(
        id: 'fixed-id',
        date: date,
        timerTitle: 'Repeaters 10/5',
        isCustom: false,
        totalSeconds: 80,
        workSeconds: 10,
        restSeconds: 5,
        rounds: 6,
        preparationSeconds: 5,
      );

      expect(session.id, 'fixed-id');
      expect(session.date, date);
    });

    test('duration is rounded up from totalSeconds as current code does', () {
      final session = trainingSessionFromFinishedTimer(
        id: 'duration-id',
        date: DateTime.utc(2025),
        timerTitle: 'Duration check',
        isCustom: false,
        totalSeconds: 61,
        workSeconds: 30,
        restSeconds: 1,
        rounds: 2,
        preparationSeconds: 0,
      );

      expect(session.durationMinutes, 2);
    });
  });
}
