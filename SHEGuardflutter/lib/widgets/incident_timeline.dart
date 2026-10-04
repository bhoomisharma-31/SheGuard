import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Data class representing an incident timeline step.
class IncidentTimelineEvent {
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color lineColor;
  final String title;
  final String subtitle;

  const IncidentTimelineEvent({
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.lineColor,
    required this.title,
    required this.subtitle,
  });
}

/// Vertical Incident Timeline component matching Screen 8 of the Master Visual Reference.
/// Color progression: Coral/Red → Green → Blue → Red → Purple
class IncidentTimeline extends StatelessWidget {
  final List<IncidentTimelineEvent> events;

  const IncidentTimeline({
    super.key,
    required this.events,
  });

  static List<IncidentTimelineEvent> defaultEvents() {
    return const [
      IncidentTimelineEvent(
        time: '9:41 AM',
        icon: Icons.graphic_eq_rounded,
        iconColor: AppColors.emergencyRed,
        lineColor: AppColors.emergencyRed,
        title: 'Shake detected',
        subtitle: 'Emergency trigger',
      ),
      IncidentTimelineEvent(
        time: '9:41 AM',
        icon: Icons.shield_rounded,
        iconColor: AppColors.emergencyRed,
        lineColor: AppColors.success,
        title: 'Emergency event created',
        subtitle: 'Safety monitoring activated',
      ),
      IncidentTimelineEvent(
        time: '9:41 AM',
        icon: Icons.location_on_rounded,
        iconColor: AppColors.success,
        lineColor: AppColors.infoBlue,
        title: 'Location acquired',
        subtitle: 'Live location sharing started',
      ),
      IncidentTimelineEvent(
        time: '9:41 AM',
        icon: Icons.camera_alt_rounded,
        iconColor: AppColors.infoBlue,
        lineColor: AppColors.emergencyRed,
        title: 'Evidence collection started',
        subtitle: 'Audio and video recording',
      ),
      IncidentTimelineEvent(
        time: '9:42 AM',
        icon: Icons.crisis_alert_rounded,
        iconColor: AppColors.emergencyRed,
        lineColor: AppColors.purpleBadge,
        title: 'Threat analysis',
        subtitle: 'Medium risk detected',
      ),
      IncidentTimelineEvent(
        time: '9:42 AM',
        icon: Icons.people_alt_rounded,
        iconColor: AppColors.purpleBadge,
        lineColor: Colors.transparent,
        title: 'Trusted contacts notified',
        subtitle: '3 contacts sent message',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon node with connecting line
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Icon(event.icon, color: event.iconColor, size: 22),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: event.lineColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Timestamp
              SizedBox(
                width: 58,
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(
                    event.time,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Event description
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 8.0 : 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
