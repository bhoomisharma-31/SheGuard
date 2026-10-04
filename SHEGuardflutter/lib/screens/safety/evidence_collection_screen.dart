import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Screen 7: Evidence Collection matching Master Visual Reference.
class EvidenceCollectionScreen extends StatefulWidget {
  const EvidenceCollectionScreen({super.key});

  @override
  State<EvidenceCollectionScreen> createState() => _EvidenceCollectionScreenState();
}

class _EvidenceCollectionScreenState extends State<EvidenceCollectionScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Audio', 'Video', 'Photos', 'Location'];

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
            Icon(Icons.camera_alt_rounded, color: AppColors.primaryNavy, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Evidence Collection',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
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
              // Recording Active Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emergencyRed,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66EC1C3E),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Recording Active',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Text(
                      '00:02:18',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Filter Tabs (Audio, Video, Photos, Location)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTab == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedTab = index),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryNavy : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryNavy : AppColors.border,
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Audio Waveform Area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: CustomPaint(
                          painter: _WaveformPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.pause_rounded, color: AppColors.primaryNavy, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Recorded Evidence Header
              const Text(
                'Recorded Evidence',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              // Audio Recording Item
              _buildEvidenceItem(
                icon: Icons.mic_rounded,
                iconColor: AppColors.infoBlue,
                title: 'Audio Recording',
                subtitle: '00:02:18',
              ),

              const SizedBox(height: 12),

              // Photos Item
              _buildEvidenceItem(
                icon: Icons.camera_alt_rounded,
                iconColor: AppColors.infoBlue,
                title: 'Photos',
                subtitle: '3 files',
              ),

              const SizedBox(height: 12),

              // Location History Item
              _buildEvidenceItem(
                icon: Icons.location_on_rounded,
                iconColor: AppColors.success,
                title: 'Location History',
                subtitle: '12 records',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF87171)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final heights = [
      0.3, 0.5, 0.8, 0.4, 0.6, 0.9, 0.7, 0.5, 0.95, 0.8, 0.6,
      0.7, 0.4, 0.85, 0.9, 0.5, 0.7, 0.8, 0.4, 0.6, 0.3, 0.5,
    ];

    final spacing = size.width / heights.length;

    for (int i = 0; i < heights.length; i++) {
      final x = i * spacing + spacing / 2;
      final h = size.height * heights[i];
      final y1 = (size.height - h) / 2;
      final y2 = y1 + h;
      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
