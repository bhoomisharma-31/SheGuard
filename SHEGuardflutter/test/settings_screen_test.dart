import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheguard_flutter/main.dart';
import 'package:sheguard_flutter/screens/settings/settings_screen.dart';

void main() {
  group('SheGuard Settings UI Tests', () {
    testWidgets('1 & 10. Home bottom navigation -> Settings opens Settings screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const SheGuardApp());
      await tester.pumpAndSettle();

      // Tap Settings tab in bottom nav
      final settingsTab = find.text('Settings');
      expect(settingsTab, findsWidgets);
      await tester.tap(settingsTab.first);
      await tester.pumpAndSettle();

      // Verify SettingsScreen is active
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('2 & 3 & 8. Settings screen renders all sections and navigation rows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(showBackButton: true),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Header
      expect(find.text('Settings'), findsOneWidget);

      // 2. Verify Section Headers
      expect(find.text('Safety Features'), findsOneWidget);
      expect(find.text('Emergency'), findsOneWidget);
      expect(find.text('App'), findsOneWidget);

      // 3. Verify Switches
      expect(find.text('Safety Mode'), findsOneWidget);
      expect(find.text('Shake Detection'), findsOneWidget);
      expect(find.text('Voice Activation'), findsOneWidget);
      expect(find.text('Location Sharing'), findsOneWidget);
      expect(find.text('Threat Monitoring'), findsOneWidget);

      // 4. Verify Navigation rows
      expect(find.text('Trusted Contacts'), findsOneWidget);
      expect(find.text('Emergency Preferences'), findsOneWidget);
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('Location, Camera, Microphone'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Light / Dark / System'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('4 & 5 & 6 & 7. Toggle switches update local UI state correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(showBackButton: true),
        ),
      );
      await tester.pumpAndSettle();

      // Find all switches
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(5));

      // 4. Safety Mode toggle
      Switch safetySwitch = tester.widget<Switch>(switches.at(0));
      expect(safetySwitch.value, isTrue);
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      safetySwitch = tester.widget<Switch>(switches.at(0));
      expect(safetySwitch.value, isFalse);

      // 5. Shake Detection toggle
      Switch shakeSwitch = tester.widget<Switch>(switches.at(1));
      expect(shakeSwitch.value, isTrue);
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      shakeSwitch = tester.widget<Switch>(switches.at(1));
      expect(shakeSwitch.value, isFalse);

      // 6. Voice Activation toggle
      Switch voiceSwitch = tester.widget<Switch>(switches.at(2));
      expect(voiceSwitch.value, isTrue);
      await tester.tap(switches.at(2));
      await tester.pumpAndSettle();
      voiceSwitch = tester.widget<Switch>(switches.at(2));
      expect(voiceSwitch.value, isFalse);

      // 7. Location Sharing toggle
      Switch locationSwitch = tester.widget<Switch>(switches.at(3));
      expect(locationSwitch.value, isTrue);
      await tester.tap(switches.at(3));
      await tester.pumpAndSettle();
      locationSwitch = tester.widget<Switch>(switches.at(3));
      expect(locationSwitch.value, isFalse);
    });

    testWidgets('9. Back navigation works when opened with back button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(showBackButton: true),
                  ),
                ),
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);

      final backButton = find.byIcon(Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
    });
  });
}
