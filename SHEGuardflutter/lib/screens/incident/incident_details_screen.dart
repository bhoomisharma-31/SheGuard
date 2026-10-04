import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/incident_summary.dart';
import '../../widgets/incident_timeline.dart';
import '../safety/evidence_collection_screen.dart';

/// Screen 8: Incident Details / Timeline matching Master Visual Reference.
/// Provides a clear, chronological visual record of a safety incident.
class IncidentDetailsScreen extends StatelessWidget {
  final String title;
  final String trigger;
  final String dateText;
  final String status;
  final String duration;

  const IncidentDetailsScreen({
    super.key,
    this.title = 'Emergency Alert',
    this.trigger = 'Shake detected',
    this.dateText = '3 Oct 2026 • 9:41 AM',
    this.status = 'Resolved',
    this.duration = '12 min',
  });

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
            Icon(Icons.feed_rounded, color: AppColors.primaryNavy, size: 20),
            SizedBox(width: 8),
            Text(
              'Incident Details',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Incident Summary Card
              IncidentSummaryCard(
                title: title,
                trigger: trigger,
                dateText: dateText,
                status: status,
                duration: duration,
              ),

              const SizedBox(height: 24),

              // 2. Vertical Timeline (Screen 8 Core)
              IncidentTimeline(
                events: IncidentTimeline.defaultEvents(),
              ),

              const SizedBox(height: 16),

              // 3. Evidence Summary Card
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EvidenceCollectionScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Flexible(
                            child: Text(
                              'Recorded Evidence',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '4 items',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildEvidenceBadge(Icons.mic_rounded, 'Audio', AppColors.infoBlue),
                          const SizedBox(width: 8),
                          _buildEvidenceBadge(Icons.location_on_rounded, 'Location', AppColors.success),
                          const SizedBox(width: 8),
                          _buildEvidenceBadge(Icons.photo_camera_rounded, 'Photos', AppColors.purpleBadge),
                          const SizedBox(width: 8),
                          _buildEvidenceBadge(Icons.list_alt_rounded, 'Log', AppColors.primaryNavy),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceBadge(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
