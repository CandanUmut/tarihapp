import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final String label;
  const ProgressRing({super.key, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (c, v, _) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
