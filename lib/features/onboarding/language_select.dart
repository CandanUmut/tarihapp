import 'package:flutter/material.dart';

class LanguageSelect extends StatelessWidget {
  const LanguageSelect({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.englishLabel,
    required this.turkishLabel,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final String englishLabel;
  final String turkishLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'en', label: Text(englishLabel)),
            ButtonSegment(value: 'tr', label: Text(turkishLabel)),
          ],
          selected: {selected},
          onSelectionChanged: (value) => onChanged(value.first),
        ),
      ],
    );
  }
}
