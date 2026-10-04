import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheguard_flutter/main.dart';
import 'package:sheguard_flutter/screens/emergency/emergency_screen.dart';

void main() {
  group('SheGuard Emergency / Alert Screen Tests', () {
    testWidgets('Home -> SOS navigates to Emergency Screen with all required elements',
        (WidgetTester tester) async {
      // Set realistic mobile phone viewport
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const SheGuardApp());
      await tester.pumpAndSettle();

      // Tap SOS button on Home screen
      final sosButtonFinder = find.text('SOS');
      expect(sosButtonFinder, findsOneWidget);
      await tester.tap(sosButtonFinder);
      await tester.pump(); // Start transition
      await tester.pump(const Duration(milliseconds: 500)); // Complete transition

      // 1. Verify Emergency Active header
      expect(find.text('EMERGENCY ACTIVE'), findsOneWidget);
      expect(find.text('Help is being coordinated'), findsOneWidget);

      // Verify SheGuard logo is NOT repeated on Emergency screen
      expect(find.byType(Image), findsNothing);

      // 2. Verify Timer is visible
      expect(find.textContaining('Since '), findsOneWidget);

      // 3. Verify Trigger source card
      expect(find.text('Alert Triggered By'), findsOneWidget);
      expect(find.text('Manual SOS'), findsOneWidget);

      // 4. Verify Location status card
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Location available'), findsOneWidget);

      // 5. Verify Trusted Contact status card
      expect(find.text('Trusted Contact'), findsOneWidget);
      expect(find.text('Notification sent'), findsOneWidget);

      // 6. Verify Evidence Collection status card
      expect(find.text('Evidence Collection'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      // 7. Verify Threat Analysis status card
      expect(find.text('Threat Analysis'), findsOneWidget);
      expect(find.text('Analyzing...'), findsOneWidget);

      // 8. Verify Resolve Alert button
      final resolveButtonFinder = find.text('Resolve Alert');
      expect(resolveButtonFinder, findsOneWidget);
      await tester.ensureVisible(resolveButtonFinder);

      // Tap Resolve Alert -> Shows confirmation dialog
      await tester.tap(resolveButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Resolve this emergency alert?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Resolve'), findsOneWidget);

      // Tap Cancel -> dialog dismissed, still on Emergency screen
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('EMERGENCY ACTIVE'), findsOneWidget);

      // Tap Resolve Alert again -> Tap Resolve -> navigates back to Home
      await tester.tap(resolveButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Resolve'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Back on Home screen
      expect(find.text('EMERGENCY ACTIVE'), findsNothing);
      expect(find.text('SOS'), findsOneWidget);
    });

    testWidgets('EmergencyScreen standalone widget test with custom trigger',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyScreen(triggerSource: 'Shake Detection'),
        ),
      );
      await tester.pump();

      expect(find.text('EMERGENCY ACTIVE'), findsOneWidget);
      expect(find.text('Shake Detection'), findsOneWidget);
    });
  });
}
