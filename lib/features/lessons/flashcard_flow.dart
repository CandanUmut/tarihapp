import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/content_providers.dart';

class FlashcardFlow extends ConsumerStatefulWidget {
  const FlashcardFlow({super.key});

  @override
  ConsumerState<FlashcardFlow> createState() => _FlashcardFlowState();
}

class _FlashcardFlowState extends ConsumerState<FlashcardFlow> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final asyncLessons = ref.watch(lessonCardsProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.flashcards)),
      body: asyncLessons.when(
        data: (lessons) {
          if (lessons.isEmpty) {
            return Center(child: Text(l10n.emptyState));
          }
          final lesson = lessons[index % lessons.length];
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(lesson.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                Text(lesson.summary, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => setState(() => index += 1),
                  child: Text(l10n.actionContinue),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
