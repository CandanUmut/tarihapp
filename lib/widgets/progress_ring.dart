import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final String label;
  final String? subtitle;
  final double size;
  const ProgressRing({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    this.size = 120,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (c, v, _) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: colorScheme.surfaceVariant.withOpacity(0.35),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
