import 'package:flutter_test/flutter_test.dart';
import 'package:jh_app/main.dart';

void main() {
  testWidgets('app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const JHApp());
    expect(find.byType(JHApp), findsOneWidget);
  });
}
