import 'package:flutter/material.dart';

class DailyGoalSelect extends StatelessWidget {
  const DailyGoalSelect({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [5, 10, 15, 20];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text('$option'),
              selected: option == selected,
              onSelected: (_) => onChanged(option),
            ),
          )
          .toList(growable: false),
    );
  }
}
