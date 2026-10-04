import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheguard_flutter/core/theme/app_theme.dart';
import 'package:sheguard_flutter/screens/home/home_screen.dart';
import 'package:sheguard_flutter/screens/chat/ask_sheguard_screen.dart';
import 'package:sheguard_flutter/screens/emergency/emergency_screen.dart';
import 'package:sheguard_flutter/screens/safety/route_safety_screen.dart';
import 'package:sheguard_flutter/screens/safety/threat_analysis_screen.dart';
import 'package:sheguard_flutter/screens/safety/evidence_collection_screen.dart';
import 'package:sheguard_flutter/screens/safety/incident_timeline_screen.dart';
import 'package:sheguard_flutter/screens/history/history_screen.dart';
import 'package:sheguard_flutter/screens/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> captureScreen(WidgetTester tester, Widget screen, String filename) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: screen,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(filename),
    );
  }

  testWidgets('Render Screen 1: Home Initial', (tester) async {
    await captureScreen(tester, const HomeScreen(initialArmed: false), 'screen1_home_initial.png');
  });

  testWidgets('Render Screen 2: Home Armed', (tester) async {
    await captureScreen(tester, const HomeScreen(initialArmed: true), 'screen2_home_armed.png');
  });

  testWidgets('Render Screen 3: Ask SheGuard Initial', (tester) async {
    await captureScreen(tester, const AskSheGuardScreen(startWithSampleConversation: false), 'screen3_ask_sheguard_initial.png');
  });

  testWidgets('Render Screen 3: Ask SheGuard Conversation', (tester) async {
    await captureScreen(tester, const AskSheGuardScreen(startWithSampleConversation: true), 'screen3_ask_sheguard.png');
  });

  testWidgets('Render Screen 4: Emergency Active', (tester) async {
    await captureScreen(tester, const EmergencyScreen(), 'screen4_emergency_active.png');
  });

  testWidgets('Render Screen 5: Route Safety', (tester) async {
    await captureScreen(tester, const RouteSafetyScreen(), 'screen5_route_safety.png');
  });

  testWidgets('Render Screen 6: Threat Analysis', (tester) async {
    await captureScreen(tester, const ThreatAnalysisScreen(), 'screen6_threat_analysis.png');
  });

  testWidgets('Render Screen 7: Evidence Collection', (tester) async {
    await captureScreen(tester, const EvidenceCollectionScreen(), 'screen7_evidence_collection.png');
  });

  testWidgets('Render Screen 8: Incident Timeline', (tester) async {
    await captureScreen(tester, const IncidentTimelineScreen(), 'screen8_incident_timeline.png');
  });

  testWidgets('Render Screen 9: History', (tester) async {
    await captureScreen(tester, const HistoryScreen(showBackButton: true), 'screen9_history.png');
  });

  testWidgets('Render Screen 10: Settings', (tester) async {
    await captureScreen(tester, const SettingsScreen(showBackButton: true), 'screen10_settings.png');
  });
}
