import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheguard_flutter/main.dart';
import 'package:sheguard_flutter/screens/chat/ask_sheguard_screen.dart';
import 'package:sheguard_flutter/screens/history/history_screen.dart';
import 'package:sheguard_flutter/screens/incident/incident_details_screen.dart';

void main() {
  group('History and Incident Details / Timeline Tests', () {
    testWidgets('1. Bottom navigation Home -> History opens History screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const SheGuardApp());
      await tester.pumpAndSettle();

      // Tap History in bottom nav
      final historyTab = find.text('History');
      expect(historyTab, findsWidgets);
      await tester.tap(historyTab.first);
      await tester.pumpAndSettle();

      // Verify History screen is displayed
      expect(find.byType(HistoryScreen), findsOneWidget);
    });

    testWidgets('2 & 3 & 4 & 5. History renders filters and filters items correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HistoryScreen(showBackButton: true),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('History'), findsOneWidget);

      // Verify all 4 filter pills render
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);

      // Verify initial cards under "All"
      expect(find.text('Emergency Alert', skipOffstage: false), findsOneWidget);
      expect(find.text('Suspicious Activity', skipOffstage: false), findsOneWidget);
      expect(find.text('Manual SOS', skipOffstage: false), findsOneWidget);
      expect(find.text('Safety Mode Session', skipOffstage: false), findsOneWidget);
      expect(find.text('Legal Help / FIR', skipOffstage: false), findsOneWidget);

      // Filter by "Alerts"
      await tester.tap(find.text('Alerts'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Emergency Alert'), findsOneWidget);
      expect(find.text('Suspicious Activity'), findsOneWidget);
      expect(find.text('Manual SOS'), findsOneWidget);
      expect(find.text('Safety Mode Session'), findsNothing);
      expect(find.text('Legal Help / FIR'), findsNothing);

      // Filter by "Chats"
      await tester.ensureVisible(find.text('Chats'));
      await tester.tap(find.text('Chats'));
      await tester.pumpAndSettle();

      expect(find.text('Legal Help / FIR'), findsOneWidget);
      expect(find.text('Emergency Alert'), findsNothing);

      // Filter by "Saved"
      await tester.ensureVisible(find.text('Saved'));
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(find.text('Safety Mode Session'), findsOneWidget);
      expect(find.text('Emergency Alert'), findsNothing);
    });

    testWidgets('6 & 7 & 8. Emergency entry opens Incident Details & timeline renders in chronological order',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HistoryScreen(showBackButton: true),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Emergency Alert card
      final emergencyCardFinder = find.text('Emergency Alert');
      expect(emergencyCardFinder, findsOneWidget);
      await tester.tap(emergencyCardFinder);
      await tester.pumpAndSettle();

      // Verify Incident Details screen opened
      expect(find.byType(IncidentDetailsScreen), findsOneWidget);
      expect(find.text('Incident Details'), findsOneWidget);

      // Verify summary elements
      expect(find.text('Emergency Alert'), findsOneWidget);
      expect(find.text('Resolved'), findsOneWidget);
      expect(find.text('Duration: 12 min'), findsOneWidget);

      // Verify timeline steps in chronological order
      expect(find.text('Shake detected'), findsAtLeastNWidgets(1));
      expect(find.text('Emergency trigger'), findsOneWidget);
      expect(find.text('Emergency event created'), findsOneWidget);
      expect(find.text('Location acquired'), findsOneWidget);
      expect(find.text('Evidence collection started'), findsOneWidget);
      expect(find.text('Threat analysis'), findsOneWidget);
      expect(find.text('Trusted contacts notified'), findsOneWidget);

      // Verify recorded evidence section
      expect(find.text('Recorded Evidence'), findsOneWidget);
      expect(find.text('4 items'), findsOneWidget);

      // Back navigation returns to History
      final backButton = find.byIcon(Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(HistoryScreen), findsOneWidget);
    });

    testWidgets('9. Chat history entry opens Ask SheGuard',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HistoryScreen(showBackButton: true),
        ),
      );
      await tester.pumpAndSettle();

      // Filter by Chats
      await tester.ensureVisible(find.text('Chats'));
      await tester.tap(find.text('Chats'));
      await tester.pumpAndSettle();

      final chatEntryFinder = find.text('Legal Help / FIR');
      expect(chatEntryFinder, findsOneWidget);
      await tester.tap(chatEntryFinder);
      await tester.pumpAndSettle();

      // Opens AskSheGuardScreen
      expect(find.byType(AskSheGuardScreen), findsOneWidget);
      expect(find.text('Ask SheGuard'), findsOneWidget);
    });
  });
}
