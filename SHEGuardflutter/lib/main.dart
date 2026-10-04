import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/ask_sheguard_screen.dart';
import 'screens/emergency/emergency_screen.dart';
import 'screens/safety/route_safety_screen.dart';
import 'screens/safety/threat_analysis_screen.dart';
import 'screens/safety/evidence_collection_screen.dart';
import 'screens/safety/incident_timeline_screen.dart';
import 'screens/incident/incident_details_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SheGuardApp());
}

class SheGuardApp extends StatelessWidget {
  const SheGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SheGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/home_armed': (context) => const HomeScreen(initialArmed: true),
        '/chat': (context) => const AskSheGuardScreen(),
        '/chat_conversation': (context) => const AskSheGuardScreen(startWithSampleConversation: true),
        '/emergency': (context) => const EmergencyScreen(),
        '/route_safety': (context) => const RouteSafetyScreen(),
        '/threat_analysis': (context) => const ThreatAnalysisScreen(),
        '/evidence': (context) => const EvidenceCollectionScreen(),
        '/timeline': (context) => const IncidentTimelineScreen(),
        '/incident_details': (context) => const IncidentDetailsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
