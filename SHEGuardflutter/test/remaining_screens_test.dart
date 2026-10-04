import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheguard_flutter/main.dart';
import 'package:sheguard_flutter/screens/safety/route_safety_screen.dart';
import 'package:sheguard_flutter/screens/safety/threat_analysis_screen.dart';
import 'package:sheguard_flutter/screens/safety/evidence_collection_screen.dart';
import 'package:sheguard_flutter/screens/emergency/emergency_screen.dart';
import 'package:sheguard_flutter/screens/incident/incident_details_screen.dart';

void main() {
  group('SheGuard Remaining Screens & Navigation Tests (Step 8)', () {
    testWidgets('1. Route Safety screen renders all visual reference elements',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: RouteSafetyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Live Location'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Map labels
      expect(find.text('Airoli'), findsOneWidget);
      expect(find.text('NAVI MUMBAI'), findsOneWidget);

      // Current Location Card
      expect(find.text('Current Location'), findsOneWidget);
      expect(find.text('Vashi, Navi Mumbai'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);

      // Suggested Safe Route Card
      expect(find.text('Suggested Safe Route'), findsOneWidget);
      expect(find.text('12 min (3.5 km)'), findsOneWidget);
      expect(find.text('Navigate'), findsOneWidget);

      // Nearby Safe Places
      expect(find.text('Nearby Safe Places'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);
      expect(find.text('Police Station'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget);
      expect(find.text('Public Place'), findsOneWidget);
      expect(find.text('1.2 km'), findsOneWidget);
      expect(find.text('2.8 km'), findsOneWidget);
      expect(find.text('1.5 km'), findsOneWidget);
    });

    testWidgets('2. Threat Analysis screen renders all visual reference elements',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ThreatAnalysisScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Threat Analysis'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Threat Level Card
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Threat Level'), findsOneWidget);
      expect(find.text('Last updated 9:42 AM'), findsOneWidget);

      // Factors Considered
      expect(find.text('Factors Considered'), findsOneWidget);
      expect(find.text('Voice analysis'), findsOneWidget);
      expect(find.text('Unusual stress pattern detected'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('In a low safety area'), findsOneWidget);
      expect(find.text('Recent activity'), findsOneWidget);
      expect(find.text('Unusual movement pattern'), findsOneWidget);
      expect(find.text('User input'), findsOneWidget);
      expect(find.text('Emergency keyword detected'), findsOneWidget);

      // Automated Notice Banner
      expect(
        find.text('This is an automated analysis. It helps SheGuard respond better.'),
        findsOneWidget,
      );
    });

    testWidgets('3. Evidence Collection screen renders and tab switching works',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EvidenceCollectionScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Evidence Collection'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Recording Active Banner
      expect(find.text('Recording Active'), findsOneWidget);
      expect(find.text('00:02:18'), findsNWidgets(2)); // in banner and in audio item

      // Filter tabs
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Video'), findsOneWidget);
      expect(find.text('Photos'), findsNWidgets(2)); // in tab and in evidence item
      expect(find.text('Location'), findsOneWidget);

      // Audio waveform and pause control
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

      // Recorded Evidence
      expect(find.text('Recorded Evidence'), findsOneWidget);
      expect(find.text('Audio Recording'), findsOneWidget);
      expect(find.text('3 files'), findsOneWidget);
      expect(find.text('Location History'), findsOneWidget);
      expect(find.text('12 records'), findsOneWidget);

      // Switch tab to Video
      await tester.tap(find.text('Video'));
      await tester.pumpAndSettle();

      // Switch tab to Photos
      await tester.tap(find.text('Photos').first);
      await tester.pumpAndSettle();
    });

    testWidgets('4. Navigation: Emergency Screen -> Route Safety Screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Location status card
      await tester.tap(find.text('Location available'));
      await tester.pumpAndSettle();

      // Should be on Route Safety screen
      expect(find.text('Live Location'), findsOneWidget);
      expect(find.text('Vashi, Navi Mumbai'), findsOneWidget);

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Back on Emergency Screen
      expect(find.text('Emergency Active'), findsOneWidget);
    });

    testWidgets('5. Navigation: Emergency Screen -> Threat Analysis Screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Threat Analysis status card
      await tester.tap(find.text('Threat Analysis'));
      await tester.pumpAndSettle();

      // Should be on Threat Analysis screen
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Factors Considered'), findsOneWidget);

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Back on Emergency Screen
      expect(find.text('Emergency Active'), findsOneWidget);
    });

    testWidgets('6. Navigation: Emergency Screen -> Evidence Collection Screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Evidence Collection status card
      await tester.tap(find.text('Evidence Collection'));
      await tester.pumpAndSettle();

      // Should be on Evidence Collection screen
      expect(find.text('Recording Active'), findsOneWidget);

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Back on Emergency Screen
      expect(find.text('Emergency Active'), findsOneWidget);
    });

    testWidgets('7. Navigation: Incident Details -> Evidence Collection Screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: IncidentDetailsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll and tap Recorded Evidence card
      await tester.ensureVisible(find.text('Recorded Evidence'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Recorded Evidence'));
      await tester.pumpAndSettle();

      // Should open Evidence Collection
      expect(find.text('Recording Active'), findsOneWidget);
      expect(find.text('00:02:18'), findsWidgets);

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Incident Details'), findsOneWidget);
    });

    testWidgets('8. Navigation: Home Armed Screen -> Route Safety Screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const SheGuardApp());
      await tester.pumpAndSettle();

      // Turn on Armed Mode
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Tap Location Sharing row in Armed mode
      await tester.tap(find.text('Location Sharing'));
      await tester.pumpAndSettle();

      expect(find.text('Live Location'), findsOneWidget);

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Should be back on Armed Home
      expect(find.text('Armed at 9:41 AM'), findsOneWidget);
    });
  });
}
