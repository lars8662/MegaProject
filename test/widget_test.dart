import 'package:climbing_diary/main.dart';
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
}
