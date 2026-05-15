import 'package:climbing_diary/models/training_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrainingSession serialization', () {
    test('fromJson handles old/minimal saved data without throwing', () {
      expect(
        () => TrainingSession.fromJson(<String, dynamic>{
          'id': 'legacy-1',
          'date': '2024-01-02T10:30:00.000',
        }),
        returnsNormally,
      );
    });

    test('missing optional fields use current fromJson defaults', () {
      final before = DateTime.now();
      final session = TrainingSession.fromJson(<String, dynamic>{});
      final after = DateTime.now();

      expect(session.id, isNotEmpty);
      expect(int.tryParse(session.id), isNotNull);
      expect(session.type, 'Боулдеринг');
      expect(session.date.isBefore(before), isFalse);
      expect(session.date.isAfter(after), isFalse);
      expect(session.durationMinutes, 0);
      expect(session.location, 'Скалодром');
      expect(session.intensity, 5);
      expect(session.effort, 'Норма');
      expect(session.notes, '');
      expect(session.exerciseName, isNull);
      expect(session.source, isNull);
      expect(session.rounds, isNull);
      expect(session.repsPerRound, isNull);
      expect(session.extraWeightKg, isNull);
      expect(session.workSeconds, isNull);
      expect(session.restSeconds, isNull);
      expect(session.preparationSeconds, isNull);
    });

    test('toJson/fromJson round trip preserves normal training session fields', () {
      final original = TrainingSession(
        id: 'session-1',
        type: 'Трудность',
        date: DateTime.utc(2025, 3, 14, 9, 26),
        durationMinutes: 95,
        location: 'Скалодром Север',
        intensity: 8,
        effort: 'Тяжело',
        notes: 'Разминка, трассы 6b-7a, заминка.',
      );

      final restored = TrainingSession.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.date, original.date);
      expect(restored.durationMinutes, original.durationMinutes);
      expect(restored.location, original.location);
      expect(restored.intensity, original.intensity);
      expect(restored.effort, original.effort);
      expect(restored.notes, original.notes);
    });

    test('toJson/fromJson round trip preserves timer-related fields', () {
      final original = TrainingSession(
        id: 'timer-session-1',
        type: 'Фингерборд',
        date: DateTime.utc(2025, 4, 10, 18, 45),
        durationMinutes: 30,
        location: 'Дом',
        intensity: 7,
        effort: 'Норма',
        notes: 'Интервалы на фингерборде.',
        exerciseName: 'Висы 7/3',
        source: 'timer',
        rounds: 6,
        repsPerRound: 5,
        extraWeightKg: '12.5',
        workSeconds: 7,
        restSeconds: 3,
        preparationSeconds: 20,
      );

      final restored = TrainingSession.fromJson(original.toJson());

      expect(restored.exerciseName, original.exerciseName);
      expect(restored.source, original.source);
      expect(restored.rounds, original.rounds);
      expect(restored.repsPerRound, original.repsPerRound);
      expect(restored.extraWeightKg, original.extraWeightKg);
      expect(restored.workSeconds, original.workSeconds);
      expect(restored.restSeconds, original.restSeconds);
      expect(restored.preparationSeconds, original.preparationSeconds);
      expect(restored.isTimerSession, isTrue);
    });
  });
}
