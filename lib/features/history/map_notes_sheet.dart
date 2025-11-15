import 'package:flutter/material.dart';

class MapNotesSheet extends StatelessWidget {
  const MapNotesSheet({super.key, required this.prophet});

  final String prophet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prophet, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Geography notes and historical highlights for $prophet.'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
