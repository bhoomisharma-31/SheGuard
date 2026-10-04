import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Screen 5: Route Safety / Live Location matching Master Visual Reference.
class RouteSafetyScreen extends StatelessWidget {
  const RouteSafetyScreen({super.key});

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
        title: const Text(
          'Live Location',
          style: TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Map representation area matching reference
              Container(
                height: 260,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F0E8),
                ),
                child: Stack(
                  children: [
                    // Roads & rivers graphics
                    CustomPaint(
                      size: const Size(double.infinity, 260),
                      painter: _MapCanvasPainter(),
                    ),
                    // Location names on map
                    const Positioned(
                      top: 40,
                      left: 60,
                      child: Text(
                        'Airoli',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 70,
                      right: 60,
                      child: Text(
                        'NAVI MUMBAI',
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    // Blue pulsing user location pin
                    Positioned(
                      top: 110,
                      left: 110,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.infoBlue.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.infoBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Red emergency destination marker with halo
                    Positioned(
                      top: 80,
                      right: 110,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emergencyRed.withValues(alpha: 0.2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: AppColors.emergencyRed,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Location Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.infoBlueLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.infoBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Current Location',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Vashi, Navi Mumbai',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Live',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Suggested Safe Route Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.alt_route_rounded,
                              color: AppColors.primaryNavy,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Suggested Safe Route',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '12 min (3.5 km)',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.navigation_rounded, size: 14),
                            label: const Text(
                              'Navigate',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Nearby Safe Places Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Flexible(
                          child: Text(
                            'Nearby Safe Places',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'View all',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Safe Places Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SafePlaceItem(
                            icon: Icons.shield_rounded,
                            iconColor: AppColors.infoBlue,
                            iconBg: AppColors.infoBlueLight,
                            title: 'Police Station',
                            distance: '1.2 km',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SafePlaceItem(
                            icon: Icons.local_hospital_rounded,
                            iconColor: AppColors.emergencyRed,
                            iconBg: AppColors.emergencyRedLight,
                            title: 'Hospital',
                            distance: '2.8 km',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SafePlaceItem(
                            icon: Icons.storefront_rounded,
                            iconColor: AppColors.success,
                            iconBg: AppColors.successLight,
                            title: 'Public Place',
                            distance: '1.5 km',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafePlaceItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String distance;

  const _SafePlaceItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            distance,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final riverPaint = Paint()
      ..color = const Color(0xFFC7E2E8)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // River
    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.7);
    riverPath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.55,
      size.width * 0.5,
      size.height,
    );
    canvas.drawPath(riverPath, riverPaint);

    // Roads
    final roadPath1 = Path();
    roadPath1.moveTo(0, 80);
    roadPath1.cubicTo(size.width * 0.3, 100, size.width * 0.6, 60, size.width, 120);
    canvas.drawPath(roadPath1, roadPaint);

    final roadPath2 = Path();
    roadPath2.moveTo(size.width * 0.45, 0);
    roadPath2.lineTo(size.width * 0.55, size.height);
    canvas.drawPath(roadPath2, roadPaint);

    // Minor roads
    final roadPath3 = Path();
    roadPath3.moveTo(size.width * 0.2, 0);
    roadPath3.lineTo(size.width * 0.3, size.height);
    canvas.drawPath(roadPath3, secondaryRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
