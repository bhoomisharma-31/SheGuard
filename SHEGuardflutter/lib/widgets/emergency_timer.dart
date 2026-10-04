import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A prominent timer that counts up from 00:00 when the emergency screen opens.
/// Rendered with crisp white typography for the dark emergency theme.
class EmergencyTimer extends StatefulWidget {
  const EmergencyTimer({super.key});

  @override
  State<EmergencyTimer> createState() => _EmergencyTimerState();
}

class _EmergencyTimerState extends State<EmergencyTimer> {
  late final Stopwatch _stopwatch;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatDuration(elapsed),
          style: const TextStyle(
            color: AppColors.textOnDark,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Since ${TimeOfDay.now().format(context)}',
          style: const TextStyle(
            color: AppColors.textOnDarkMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
