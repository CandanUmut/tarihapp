import 'package:flutter/material.dart';

import '../../data/models/streak.dart';
import '../../widgets/streak_heatmap.dart';

class StreakCalendar extends StatelessWidget {
  const StreakCalendar({super.key, required this.stats});

  final StreakStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current: ${stats.current}'),
        Text('Longest: ${stats.longest}'),
        const SizedBox(height: 12),
        StreakHeatmap(days: stats.days),
      ],
    );
  }
}
