import 'dart:convert';

import 'package:climbing_diary/main.dart';
import 'package:climbing_diary/models/training_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts and shows Russian shell title', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const ProviderScope(child: ClimbingDiaryApp()));
    await tester.pump();

    expect(find.text('Дневник скалолаза'), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
  });

  testWidgets('App starts when saved training sessions already exist', (
    WidgetTester tester,
  ) async {
    const storageKey = 'training_sessions_v1';
    final savedSession = TrainingSession(
      id: 'startup-saved-session',
      type: 'Трудность',
      date: DateTime.utc(2025, 3, 14, 9, 26),
      durationMinutes: 90,
      location: 'Скалодром Север',
      intensity: 8,
      effort: 'Тяжело',
      notes: 'Разминка, трассы 6b-7a, заминка.',
    );

    SharedPreferences.setMockInitialValues(<String, Object>{
      storageKey: <String>[jsonEncode(savedSession.toJson())],
    });

    await tester.pumpWidget(const ProviderScope(child: ClimbingDiaryApp()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Дневник скалолаза'), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);

    await tester.tap(find.text('Дневник'));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Тренировочный дневник'), findsOneWidget);
    expect(find.text('Трудность · Скалодром Север'), findsOneWidget);
    expect(find.text('Разминка, трассы 6b-7a, заминка.'), findsOneWidget);
  });
}
