import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheguard_flutter/main.dart';

void main() {
  testWidgets('SheGuard Home Screen specification verification', (WidgetTester tester) async {
    await tester.pumpWidget(const SheGuardApp());
    await tester.pumpAndSettle();

    // 1. Verify Top-left brand elements: SheGuard text & Settings icon
    expect(find.text('SheGuard'), findsNothing); // It's RichText with 'She' and 'Guard'
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // 2. Verify prohibited slogans are NOT present
    expect(find.text("Stay Safe, You're in Control"), findsNothing);
    expect(find.text('Your Safety Companion'), findsNothing);

    // 3. Verify SOS Button & primary text
    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('Tap to send emergency alert'), findsOneWidget);

    // 4. Verify Arm Safety Mode & toggle
    expect(find.text('Arm Safety Mode'), findsOneWidget);
    expect(find.text('Enable shake & voice detection'), findsOneWidget);
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    Switch switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, false); // Initial state is OFF

    // Toggle switch
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, true);

    // 5. Verify Ask SheGuard card
    expect(find.text('Ask SheGuard'), findsOneWidget);
    expect(find.text('Get help, legal info or guidance'), findsOneWidget);

    // 6. Verify Location status row
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);

    // 7. Verify Bottom navigation items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Legal Help'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });
}
