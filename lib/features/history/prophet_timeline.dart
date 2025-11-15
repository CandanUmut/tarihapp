import 'package:flutter/material.dart';

class ProphetTimeline extends StatelessWidget {
  const ProphetTimeline({super.key, required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final prophets = const [
      'Âdem',
      'Nûḥ',
      'Ibrâhîm',
      'Mûsâ',
      'Dâwûd',
      'Sulaymân',
      'ʿĪsā',
      'Muhammad ﷺ',
    ];
    return Column(
      children: prophets
          .map(
            (prophet) => ListTile(
              title: Text(prophet),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onTap(prophet),
            ),
          )
          .toList(growable: false),
    );
  }
}
