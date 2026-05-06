import 'package:climbing_diary/screens/timers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Timers picker has restored presets and no Recent section', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: TimersScreen()),
        ),
      ),
    );

    expect(find.text('Последние'), findsNothing);
    expect(find.text('Recent'), findsNothing);
    expect(find.text('Repeaters 7/3'), findsWidgets);
    expect(find.text('Repeaters 10/5'), findsWidgets);
    expect(find.text('PIMA 2/4'), findsWidgets);
    expect(find.text('CF Endurance 7/3 · 6 мин'), findsWidgets);
    expect(find.text('Max Hang'), findsWidgets);
    expect(find.text('ARC / лёгкий объём'), findsWidgets);
  });
}
