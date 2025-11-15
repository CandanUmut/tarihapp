import 'package:flutter/material.dart';

import '../../widgets/app_card.dart';
import '../../widgets/progress_ring.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key, required this.percent, required this.label});

  final double percent;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primaryContainer.withOpacity(0.8),
          theme.colorScheme.secondaryContainer.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      background: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 400;
          final content = [
            ProgressRing(percent: percent, label: label),
            const SizedBox(width: 24, height: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay consistent — every completed lesson updates this tracker instantly.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ];
          return isWide
              ? Row(children: content)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProgressRing(percent: percent, label: label),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stay consistent — every completed lesson updates this tracker instantly.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.9),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
