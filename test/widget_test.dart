import 'package:flutter_test/flutter_test.dart';
import 'package:astrozen/main.dart';

void main() {
  testWidgets('AstroZen app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AstroZenApp());
    expect(find.byType(AstroZenApp), findsOneWidget);
  });
}
