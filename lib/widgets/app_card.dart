import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.background,
    this.gradient,
    this.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? background;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: gradient == null ? background ?? theme.colorScheme.surface : null,
      gradient: gradient,
      border: border ?? Border.all(color: theme.colorScheme.outlineVariant, width: 0.6),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(theme.brightness == Brightness.light ? 0.04 : 0.25),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );

    final content = Container(
      decoration: decoration,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: theme.colorScheme.primary.withOpacity(0.08),
          highlightColor: theme.colorScheme.primary.withOpacity(0.04),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: content,
    );
  }
}
