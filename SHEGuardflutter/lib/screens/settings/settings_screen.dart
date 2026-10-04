import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/settings_section.dart';
import '../../widgets/settings_switch_row.dart';
import '../../widgets/settings_navigation_row.dart';

/// Screen 10: Settings matching Master Visual Reference.
class SettingsScreen extends StatefulWidget {
  final bool showBackButton;

  const SettingsScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _safetyMode = true;
  bool _shakeDetection = true;
  bool _voiceActivation = true;
  bool _locationSharing = true;
  bool _threatMonitoring = true;

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.settings_rounded, color: AppColors.primaryNavy, size: 22),
            SizedBox(width: 8),
            Text(
              'Settings',
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Safety Features Section
              SettingsSection(
                title: 'Safety Features',
                children: [
                  SettingsSwitchRow(
                    icon: Icons.security_rounded,
                    iconColor: AppColors.success,
                    title: 'Safety Mode',
                    subtitle: 'Enable shake & voice detection',
                    value: _safetyMode,
                    onChanged: (v) => setState(() => _safetyMode = v),
                  ),
                  const Divider(height: 1, indent: 52, color: AppColors.border),
                  SettingsSwitchRow(
                    icon: Icons.graphic_eq_rounded,
                    iconColor: AppColors.infoBlue,
                    title: 'Shake Detection',
                    subtitle: 'Detect movement while armed',
                    value: _shakeDetection,
                    onChanged: (v) => setState(() => _shakeDetection = v),
                  ),
                  const Divider(height: 1, indent: 52, color: AppColors.border),
                  SettingsSwitchRow(
                    icon: Icons.mic_rounded,
                    iconColor: AppColors.infoBlue,
                    title: 'Voice Activation',
                    subtitle: 'Listen for emergency keyword',
                    value: _voiceActivation,
                    onChanged: (v) => setState(() => _voiceActivation = v),
                  ),
                  const Divider(height: 1, indent: 52, color: AppColors.border),
                  SettingsSwitchRow(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.emergencyRed,
                    title: 'Location Sharing',
                    subtitle: 'Active during safety session',
                    value: _locationSharing,
                    onChanged: (v) => setState(() => _locationSharing = v),
                  ),
                  const Divider(height: 1, indent: 52, color: AppColors.border),
                  SettingsSwitchRow(
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.primaryNavy,
                    title: 'Threat Monitoring',
                    value: _threatMonitoring,
                    onChanged: (v) => setState(() => _threatMonitoring = v),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. Emergency Section
              SettingsSection(
                title: 'Emergency',
                children: const [
                  SettingsNavigationRow(
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.primaryNavy,
                    title: 'Trusted Contacts',
                    subtitle: 'Manage primary and emergency contacts',
                  ),
                  Divider(height: 1, indent: 52, color: AppColors.border),
                  SettingsNavigationRow(
                    icon: Icons.settings_suggest_rounded,
                    iconColor: AppColors.primaryNavy,
                    title: 'Emergency Preferences',
                    subtitle: 'Configure automated actions',
                  ),
                  Divider(height: 1, indent: 52, color: AppColors.border),
                  SettingsNavigationRow(
                    icon: Icons.verified_user_rounded,
                    iconColor: AppColors.primaryNavy,
                    title: 'Permissions',
                    subtitle: 'Location, Camera, Microphone',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. App Section
              SettingsSection(
                title: 'App',
                children: const [
                  SettingsNavigationRow(
                    icon: Icons.palette_rounded,
                    iconColor: AppColors.primaryNavy,
                    title: 'Appearance',
                    trailingText: 'Light / Dark / System',
                  ),
                  Divider(height: 1, indent: 52, color: AppColors.border),
                  SettingsNavigationRow(
                    icon: Icons.language_rounded,
                    iconColor: AppColors.primaryNavy,
                    title: 'Language',
                    trailingText: 'English',
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
