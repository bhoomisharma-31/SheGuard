import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Screen 6: Threat Analysis matching Master Visual Reference.
class ThreatAnalysisScreen extends StatelessWidget {
  const ThreatAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryNavy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shield_rounded, color: AppColors.primaryNavy, size: 20),
            SizedBox(width: 8),
            Text(
              'Threat Analysis',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Threat Level Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Shield Badge
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFEDD5), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFFF97316),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Medium',
                            style: TextStyle(
                              color: Color(0xFFEA580C),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Threat Level',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Last updated 9:42 AM',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Factors Considered
              const Text(
                'Factors Considered',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              // Factor 1: Voice Analysis
              _buildFactorItem(
                icon: Icons.mic_rounded,
                iconColor: AppColors.infoBlue,
                title: 'Voice analysis',
                subtitle: 'Unusual stress pattern detected',
              ),

              const SizedBox(height: 12),

              // Factor 2: Location
              _buildFactorItem(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.emergencyRed,
                title: 'Location',
                subtitle: 'In a low safety area',
              ),

              const SizedBox(height: 12),

              // Factor 3: Recent Activity
              _buildFactorItem(
                icon: Icons.phone_in_talk_rounded,
                iconColor: AppColors.infoBlue,
                title: 'Recent activity',
                subtitle: 'Unusual movement pattern',
              ),

              const SizedBox(height: 12),

              // Factor 4: User Input
              _buildFactorItem(
                icon: Icons.people_alt_rounded,
                iconColor: AppColors.infoBlue,
                title: 'User input',
                subtitle: 'Emergency keyword detected',
              ),

              const SizedBox(height: 24),

              // Automated notice banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD0E1FD)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppColors.infoBlue, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is an automated analysis. It helps SheGuard respond better.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFactorItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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
