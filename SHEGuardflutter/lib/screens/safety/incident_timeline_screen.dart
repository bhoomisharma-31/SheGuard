import 'package:flutter/material.dart';
import '../incident/incident_details_screen.dart';

/// Legacy alias / export for IncidentTimelineScreen pointing to IncidentDetailsScreen.
class IncidentTimelineScreen extends StatelessWidget {
  const IncidentTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const IncidentDetailsScreen();
  }
}
