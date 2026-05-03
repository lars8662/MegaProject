import 'package:climbing_diary/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const ClimbingDiaryApp());
    expect(find.text('Climbing Diary'), findsOneWidget);
  });
}
