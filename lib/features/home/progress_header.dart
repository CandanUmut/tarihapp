import 'package:flutter/material.dart';

import '../../widgets/app_card.dart';
import '../../widgets/progress_ring.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key, required this.value, required this.label});

  final double value;
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
            ProgressRing(
              value: value,
              label: '${(value * 100).clamp(0, 100).toStringAsFixed(0)}%',
              subtitle: 'completion',
              size: isWide ? 130 : 120,
            ),
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Keep your streak alive',
                        color: theme.colorScheme.secondary,
                      ),
                      _StatChip(
                        icon: Icons.emoji_objects_outlined,
                        label: 'Quick tips adapt as you progress',
                        color: theme.colorScheme.tertiary,
                      ),
                    ],
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
                    ProgressRing(
                      value: value,
                      label: '${(value * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      subtitle: 'completion',
                    ),
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
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _StatChip(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Keep your streak alive',
                          color: theme.colorScheme.secondary,
                        ),
                        _StatChip(
                          icon: Icons.emoji_objects_outlined,
                          label: 'Quick tips adapt as you progress',
                          color: theme.colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
