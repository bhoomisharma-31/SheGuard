import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/emergency_header.dart';
import '../../widgets/emergency_timer.dart';
import '../../widgets/emergency_status_card.dart';
import '../../widgets/resolve_alert_button.dart';

import '../safety/route_safety_screen.dart';
import '../safety/threat_analysis_screen.dart';
import '../safety/evidence_collection_screen.dart';

/// The Emergency / Alert screen matching Screen 4 of the Master Visual Reference.
/// Features a dark burgundy/navy emergency background, glowing siren aura,
/// white typography, dark status cards with colored badges, and a bright red resolve button.
class EmergencyScreen extends StatelessWidget {
  final String triggerSource;

  const EmergencyScreen({
    super.key,
    this.triggerSource = 'Manual SOS',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140508),
      body: Stack(
        children: [
          // Deep red radial emergency glow behind the header
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 0.85,
                  colors: [
                    Color(0xFF5A0E1A),
                    Color(0xFF330911),
                    Color(0x00140508),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Emergency Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Help is being arranged',
                              style: TextStyle(
                                color: Color(0xFFE2A0AA),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Glowing Siren Halo Icon
                        const EmergencyHeader(),

                        const SizedBox(height: 14),

                        // Timer
                        const EmergencyTimer(),

                        const SizedBox(height: 24),

                        // Trigger Source Card
                        EmergencyStatusCard(
                          icon: Icons.graphic_eq_rounded,
                          iconColor: Colors.white,
                          iconBackgroundColor: AppColors.emergencyRed,
                          title: 'Alert Triggered By',
                          status: triggerSource,
                          onTap: () {},
                        ),

                        const SizedBox(height: 10),

                        // Location Card
                        EmergencyStatusCard(
                          icon: Icons.location_on_rounded,
                          iconColor: Colors.white,
                          iconBackgroundColor: const Color(0xFF10B981),
                          title: 'Location',
                          status: 'Location available',
                          statusType: EmergencyStatusType.active,
                          badgeText: 'Active',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RouteSafetyScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // Trusted Contacts Card
                        const EmergencyStatusCard(
                          icon: Icons.people_alt_rounded,
                          iconColor: Colors.white,
                          iconBackgroundColor: Color(0xFF2563EB),
                          title: 'Trusted Contact',
                          status: 'Notification sent',
                          statusType: EmergencyStatusType.active,
                          badgeText: 'Sent',
                        ),

                        const SizedBox(height: 10),

                        // Evidence Card
                        EmergencyStatusCard(
                          icon: Icons.camera_alt_rounded,
                          iconColor: Colors.white,
                          iconBackgroundColor: const Color(0xFF8B5CF6),
                          title: 'Evidence Collection',
                          status: 'Ready',
                          statusType: EmergencyStatusType.active,
                          badgeText: 'Active',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EvidenceCollectionScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // Threat Analysis Card
                        EmergencyStatusCard(
                          icon: Icons.shield_rounded,
                          iconColor: Colors.white,
                          iconBackgroundColor: const Color(0xFF6366F1),
                          title: 'Threat Analysis',
                          status: 'Analyzing...',
                          statusType: EmergencyStatusType.pending,
                          badgeText: 'In Progress',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ThreatAnalysisScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Full width bright red Resolve Alert button
                        ResolveAlertButton(
                          onResolve: () {
                            Navigator.of(context).pop();
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
