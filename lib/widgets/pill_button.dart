import 'package:flutter/material.dart';

enum PillButtonVariant { primary, secondary, tonal }

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onPressed,
    this.padding,
    this.variant = PillButtonVariant.primary,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final PillButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callback = onPressed ?? onTap;
    final colorScheme = theme.colorScheme;
    final isPrimary = variant == PillButtonVariant.primary;
    final isTonal = variant == PillButtonVariant.tonal;

    final gradient = isPrimary
        ? LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    final Color backgroundColor;
    final Color foregroundColor;
    final BoxBorder? border;

    if (isPrimary) {
      backgroundColor = Colors.transparent;
      foregroundColor = colorScheme.onPrimary;
      border = null;
    } else if (isTonal) {
      backgroundColor = colorScheme.secondaryContainer;
      foregroundColor = colorScheme.onSecondaryContainer;
      border = Border.all(color: colorScheme.secondary.withOpacity(0.3));
    } else {
      backgroundColor = colorScheme.surface;
      foregroundColor = colorScheme.onSurface;
      border = Border.all(color: colorScheme.outlineVariant);
    }

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(24),
        gradient: gradient,
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.08 : 0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: foregroundColor),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (callback == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: callback,
        splashColor: colorScheme.primary.withOpacity(0.12),
        highlightColor: colorScheme.primary.withOpacity(0.06),
        child: child,
      ),
    );
  }
}
