import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PillButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background = variant == PillButtonVariant.primary
        ? colorScheme.primary
        : colorScheme.surfaceVariant;
    final foreground = variant == PillButtonVariant.primary
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Text(label),
    );
  }
}

enum PillButtonVariant { primary, secondary }
