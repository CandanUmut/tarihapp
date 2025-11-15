import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'map_notes_sheet.dart';
import 'prophet_timeline.dart';

class HistoryTimelineScreen extends StatelessWidget {
  const HistoryTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.timelineTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ProphetTimeline(onTap: (prophet) {
            showModalBottomSheet<void>(
              context: context,
              builder: (context) => MapNotesSheet(prophet: prophet),
            );
          }),
        ],
      ),
    );
  }
}
