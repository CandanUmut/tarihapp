import 'package:flutter/material.dart';

import '../data/models/streak.dart';

class StreakHeatmap extends StatelessWidget {
  const StreakHeatmap({super.key, required this.days});

  final List<StreakDay> days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<StreakDay>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: sorted
          .map(
            (day) => Tooltip(
              message: day.date.toString(),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: day.done
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
