import 'package:flutter_test/flutter_test.dart';
import 'package:idle_agent/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const IdleAgentApp(showOnboarding: true));
    await tester.pump();
    expect(find.text('Your phone just got smarter'), findsOneWidget);
  });
}
