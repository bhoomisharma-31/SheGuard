import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheguard_flutter/main.dart';
import 'package:sheguard_flutter/screens/chat/ask_sheguard_screen.dart';
import 'package:sheguard_flutter/screens/emergency/emergency_screen.dart';

void main() {
  group('Ask SheGuard Chat UI Tests', () {
    testWidgets('Home -> Ask SheGuard navigates to chat, shows welcome and quick suggestions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const SheGuardApp());
      await tester.pumpAndSettle();

      // Tap Ask SheGuard card on Home
      final askCardFinder = find.text('Ask SheGuard');
      expect(askCardFinder, findsOneWidget);
      await tester.tap(askCardFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Verify Header: back button, title "Ask SheGuard", security robot icon, more options icon
      expect(find.text('Ask SheGuard'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

      // 2. Verify Emergency Escalation banner: "Need immediate help?" and "SOS"
      expect(find.text('Need immediate help?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'SOS'), findsOneWidget);

      // 3. Verify Welcome screen
      expect(find.text('How can I help?'), findsOneWidget);
      expect(
        find.text('Ask about safety, legal information, or what to do next.'),
        findsOneWidget,
      );

      // 4. Verify prohibited slogans are NOT present
      expect(find.text('Your AI companion'), findsNothing);
      expect(find.text('AI-powered assistant'), findsNothing);
      expect(find.text('Ask anything'), findsNothing);

      // 5. Verify exact quick suggestions on welcome
      expect(find.text('Is this situation dangerous?'), findsOneWidget);
      expect(find.text('What should I do right now?'), findsOneWidget);
      expect(find.text('What are my legal rights?'), findsOneWidget);
      expect(find.text('How can I stay safe on this route?'), findsOneWidget);
      expect(find.text('Legal information'), findsOneWidget);

      // 6. Tap a suggestion ("What should I do right now?")
      await tester.tap(find.text('What should I do right now?'));
      await tester.pump();
      // User message is immediately added
      expect(find.text('What should I do right now?'), findsOneWidget);

      // Advance clock to trigger mock response
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // 7. Verify specific mock response
      expect(
        find.text(
          'If you feel unsafe, move to a safer or more populated place and contact someone you trust. If you are in immediate danger, use SOS.',
        ),
        findsOneWidget,
      );

      // 8. User types a custom message
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Can you help me?');
      await tester.pump();

      // Tap send button (near_me paper airplane icon)
      final sendButtonFinder = find.byKey(const ValueKey('chat_send_button'));
      expect(sendButtonFinder, findsOneWidget);
      await tester.tap(sendButtonFinder);
      await tester.pump();

      expect(find.text('Can you help me?'), findsOneWidget);

      // Advance clock for demo placeholder response
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(
        find.text("I'm here to help. This is a demo response for the chat UI."),
        findsOneWidget,
      );

      // 9. Back navigation returns to Home
      final backButtonFinder = find.byIcon(Icons.arrow_back_rounded);
      await tester.tap(backButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Back on Home
      expect(find.text('Tap to send emergency alert'), findsOneWidget);
    });

    testWidgets('Emergency banner SOS inside chat navigates to EmergencyScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AskSheGuardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final chatSosFinder = find.widgetWithText(ElevatedButton, 'SOS');
      expect(chatSosFinder, findsOneWidget);
      await tester.tap(chatSosFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EmergencyScreen), findsOneWidget);
      expect(find.text('EMERGENCY ACTIVE'), findsOneWidget);
      expect(find.text('Manual SOS (Chat)'), findsOneWidget);
    });

    testWidgets('Bottom navigation "Legal Help" opens Ask SheGuard with legal query',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const SheGuardApp());
      await tester.pumpAndSettle();

      // Tap Legal Help tab on bottom navigation bar
      final legalHelpTab = find.text('Legal Help');
      expect(legalHelpTab, findsOneWidget);
      await tester.tap(legalHelpTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Opens AskSheGuardScreen
      expect(find.byType(AskSheGuardScreen), findsOneWidget);
      expect(find.text('Ask SheGuard'), findsOneWidget);

      // Advance clock for initial legal query response
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Legal information'), findsOneWidget);
      expect(
        find.textContaining('You have the right to personal safety'),
        findsOneWidget,
      );
    });

    testWidgets('AskSheGuardScreen conversation mode displays Screen 3 reference content',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AskSheGuardScreen(startWithSampleConversation: true),
        ),
      );
      await tester.pumpAndSettle();

      // Initial assistant message
      expect(find.text("Hi, I'm SheGuard.\nHow can I help you today?"), findsOneWidget);

      // User sample message
      expect(find.text('How do I file an FIR?'), findsOneWidget);

      // Assistant response with FIR steps
      expect(find.textContaining('To file an FIR, you can:'), findsOneWidget);
      expect(find.textContaining('1. Visit the nearest police station'), findsOneWidget);

      // Compact suggestion chips
      expect(find.text('Guide me with steps'), findsOneWidget);
      expect(find.text('Show nearest police stations'), findsOneWidget);
      expect(find.text('Tell me my rights'), findsOneWidget);

      // Tapping a suggestion chip sends it and responds
      await tester.tap(find.text('Guide me with steps'));
      await tester.pump();
      expect(find.text('Guide me with steps'), findsAtLeastNWidgets(1));

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.textContaining('Steps to file an FIR:'), findsOneWidget);
    });
  });
}
