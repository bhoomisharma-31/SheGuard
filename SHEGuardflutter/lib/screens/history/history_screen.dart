import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/history_card.dart';
import '../../widgets/history_filter_pill.dart';
import '../incident/incident_details_screen.dart';
import '../chat/ask_sheguard_screen.dart';

/// Data model for local demo history records.
class HistoryRecord {
  final String id;
  final String dateText;
  final String title;
  final String subtitle;
  final String? meta;
  final String category; // 'Alerts', 'Saved', 'Chats'
  final IconData icon;
  final Color innerColor;
  final Color haloColor;
  final String status;
  final String duration;
  final String trigger;

  const HistoryRecord({
    required this.id,
    required this.dateText,
    required this.title,
    required this.subtitle,
    this.meta,
    required this.category,
    required this.icon,
    required this.innerColor,
    required this.haloColor,
    this.status = 'Resolved',
    this.duration = '12 min',
    this.trigger = 'Shake detected',
  });
}

/// Screen 9: History matching Master Visual Reference.
class HistoryScreen extends StatefulWidget {
  final bool showBackButton;

  const HistoryScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Alerts', 'Saved', 'Chats'];

  static final List<HistoryRecord> _records = [
    const HistoryRecord(
      id: '1',
      dateText: '3 Oct 2026 • 9:41 AM',
      title: 'Emergency Alert',
      subtitle: 'Shake detected • Resolved',
      meta: 'Duration: 12 min',
      category: 'Alerts',
      icon: Icons.crisis_alert_rounded,
      innerColor: AppColors.emergencyRed,
      haloColor: AppColors.emergencyRedLight,
      trigger: 'Shake detected',
      duration: '12 min',
      status: 'Resolved',
    ),
    const HistoryRecord(
      id: '2',
      dateText: '28 Sep 2026 • 7:12 PM',
      title: 'Suspicious Activity',
      subtitle: 'Voice alert • No action needed',
      category: 'Alerts',
      icon: Icons.shield_rounded,
      innerColor: AppColors.primaryNavy,
      haloColor: AppColors.infoBlueLight,
      trigger: 'Voice alert',
      duration: '5 min',
      status: 'No Action Needed',
    ),
    const HistoryRecord(
      id: '3',
      dateText: '16 Sep 2026 • 10:45 PM',
      title: 'Manual SOS',
      subtitle: 'Resolved • Duration: 8 min',
      category: 'Alerts',
      icon: Icons.crisis_alert_rounded,
      innerColor: AppColors.emergencyRed,
      haloColor: AppColors.emergencyRedLight,
      trigger: 'Manual SOS',
      duration: '8 min',
      status: 'Resolved',
    ),
    const HistoryRecord(
      id: '4',
      dateText: '10 Sep 2026 • 6:30 PM',
      title: 'Safety Mode Session',
      subtitle: 'Armed for 1 hr 15 min',
      category: 'Saved',
      icon: Icons.verified_user_rounded,
      innerColor: AppColors.success,
      haloColor: AppColors.successLight,
      trigger: 'Safety Mode Monitoring',
      duration: '1 hr 15 min',
      status: 'Completed',
    ),
    const HistoryRecord(
      id: '5',
      dateText: '8 Sep 2026 • 2:15 PM',
      title: 'Legal Help / FIR',
      subtitle: 'FIR procedure and legal assistance query',
      meta: 'Chat Consultation',
      category: 'Chats',
      icon: Icons.chat_bubble_rounded,
      innerColor: AppColors.infoBlue,
      haloColor: AppColors.infoBlueLight,
      trigger: 'Legal Query',
      duration: '10 min',
      status: 'Completed',
    ),
  ];

  List<HistoryRecord> get _filteredRecords {
    if (_selectedFilter == 0) return _records;
    final currentCategory = _filters[_selectedFilter];
    return _records.where((r) => r.category == currentCategory).toList();
  }

  void _onRecordTapped(HistoryRecord record) {
    if (record.category == 'Chats') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AskSheGuardScreen(
            startWithSampleConversation: true,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => IncidentDetailsScreen(
            title: record.title,
            trigger: record.trigger,
            dateText: record.dateText,
            status: record.status,
            duration: record.duration,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsToShow = _filteredRecords;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryNavy),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.history_rounded, color: AppColors.primaryNavy, size: 22),
            SizedBox(width: 8),
            Text(
              'History',
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Tabs (All, Alerts, Saved, Chats)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    return HistoryFilterPill(
                      label: _filters[index],
                      isSelected: _selectedFilter == index,
                      onTap: () => setState(() => _selectedFilter = index),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // History Cards
              if (recordsToShow.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text(
                    'No ${_filters[_selectedFilter]} records found',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                ...recordsToShow.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: HistoryCard(
                      dateText: record.dateText,
                      title: record.title,
                      subtitle: record.subtitle,
                      meta: record.meta,
                      icon: record.icon,
                      innerColor: record.innerColor,
                      haloColor: record.haloColor,
                      onTap: () => _onRecordTapped(record),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
