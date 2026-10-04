import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/emergency/emergency_screen.dart';
import '../../screens/chat/ask_sheguard_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/safety/route_safety_screen.dart';
import '../../screens/safety/threat_analysis_screen.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/safety_mode_card.dart';
import '../../widgets/ask_sheguard_card.dart';
import '../../widgets/location_status.dart';

class HomeScreen extends StatefulWidget {
  final bool initialArmed;

  const HomeScreen({
    super.key,
    this.initialArmed = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  late bool _isArmed;

  @override
  void initState() {
    super.initState();
    _isArmed = widget.initialArmed;
  }

  void _onToggleSafetyMode(bool value) {
    setState(() {
      _isArmed = value;
    });
  }

  void _onSosTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmergencyScreen(
          triggerSource: 'Manual SOS',
        ),
      ),
    );
  }

  void _onAskSheGuardTapped([String? initialQuery]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AskSheGuardScreen(
          initialQuery: initialQuery,
        ),
      ),
    );
  }

  void _onLocationTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RouteSafetyScreen(),
      ),
    );
  }

  void _onSettingsTapped() {
    setState(() {
      _selectedNavIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _selectedNavIndex == 0 && _isArmed;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNavIndex,
          children: [
            _isArmed ? _buildArmedHomeContent() : _buildUnarmedHomeContent(),
            const HistoryScreen(showBackButton: false),
            const AskSheGuardScreen(),
            const SettingsScreen(showBackButton: false),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryNavyDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          backgroundColor: isDark ? AppColors.primaryNavyDark : Colors.white,
          selectedItemColor: AppColors.emergencyRed,
          unselectedItemColor: isDark ? AppColors.textOnDarkMuted : AppColors.textMuted,
          onTap: (index) {
            if (index == 2) {
              _onAskSheGuardTapped('Legal information');
              return;
            }
            setState(() {
              _selectedNavIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              label: 'Legal Help',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SCREEN 1: HOME (INITIAL / UNARMED)
  // =========================================================================
  Widget _buildUnarmedHomeContent() {
    return LayoutBuilder(
      key: const ValueKey('unarmed_home'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- TOP BAR: Logo on top-left, Settings gear on top-right ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 38,
                            width: 38,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.shield, color: AppColors.emergencyRed, size: 36),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'She',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryNavy,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Guard',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.emergencyRed,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: AppColors.primaryNavy, size: 24),
                        onPressed: _onSettingsTapped,
                        tooltip: 'Settings',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // --- CENTER: SOS BUTTON ---
                  Center(
                    child: SosButton(
                      onTap: _onSosTapped,
                      isDark: false,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- LOWER SECTION: Cards ---
                  Column(
                    children: [
                      SafetyModeCard(
                        isArmed: _isArmed,
                        onToggle: _onToggleSafetyMode,
                      ),
                      const SizedBox(height: 12),
                      AskSheGuardCard(
                        onTap: () => _onAskSheGuardTapped(),
                      ),
                      const SizedBox(height: 12),
                      LocationStatusRow(
                        onTap: _onLocationTapped,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // SCREEN 2: HOME (ARMED STATE)
  // =========================================================================
  Widget _buildArmedHomeContent() {
    return LayoutBuilder(
      key: const ValueKey('armed_home'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- TOP BAR (DARK THEME) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 38,
                            width: 38,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.shield, color: AppColors.emergencyRed, size: 36),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'She',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Guard',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.emergencyRed,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
                        onPressed: _onSettingsTapped,
                        tooltip: 'Settings',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // --- SAFETY MODE ACTIVE GREEN CARD ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.armedBannerBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.armedBannerBorder, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(alpha: 0.25),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.success,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Safety Mode Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Shake & voice detection enabled',
                                style: TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Armed at 9:41 AM',
                                style: TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isArmed,
                          onChanged: _onToggleSafetyMode,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.success,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // --- CENTER: SOS BUTTON (DARK) ---
                  Center(
                    child: SosButton(
                      onTap: _onSosTapped,
                      isDark: true,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // --- ARMED FEATURES STATUS CARD ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderDark, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildArmedFeatureRow(
                          icon: Icons.phone_android_rounded,
                          title: 'Shake Detection',
                          isOn: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ThreatAnalysisScreen(),
                              ),
                            );
                          },
                        ),
                        Divider(height: 16, color: AppColors.borderDark.withValues(alpha: 0.5)),
                        _buildArmedFeatureRow(
                          icon: Icons.mic_rounded,
                          title: 'Voice Activation',
                          isOn: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ThreatAnalysisScreen(),
                              ),
                            );
                          },
                        ),
                        Divider(height: 16, color: AppColors.borderDark.withValues(alpha: 0.5)),
                        _buildArmedFeatureRow(
                          icon: Icons.location_on_rounded,
                          title: 'Location Sharing',
                          isOn: true,
                          onTap: _onLocationTapped,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // --- DISARM BUTTON ---
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onToggleSafetyMode(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.emergencyRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Disarm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  AskSheGuardCard(
                    onTap: () => _onAskSheGuardTapped(),
                  ),
                  const SizedBox(height: 12),
                  LocationStatusRow(
                    onTap: _onLocationTapped,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArmedFeatureRow({
    required IconData icon,
    required String title,
    required bool isOn,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'On',
              style: TextStyle(
                color: AppColors.textOnDarkSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.textOnDarkMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
