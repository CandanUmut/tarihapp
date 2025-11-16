import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/content_providers.dart';
import '../../widgets/error_state.dart';

class FlashcardFlow extends ConsumerStatefulWidget {
  const FlashcardFlow({super.key});

  @override
  ConsumerState<FlashcardFlow> createState() => _FlashcardFlowState();
}

class _FlashcardFlowState extends ConsumerState<FlashcardFlow> {
  final PageController _controller = PageController();
  bool reveal = false;

  @override
  Widget build(BuildContext context) {
    final asyncLessons = ref.watch(lessonCardsProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.flashcards)),
      body: asyncLessons.when(
        data: (lessons) {
          final cards = lessons
              .expand(
                (lesson) => lesson.keyPoints
                    .map((point) => _Flashcard(title: lesson.title, detail: point)),
              )
              .toList(growable: false);
          if (cards.isEmpty) {
            return const ErrorState(message: 'No flashcards ready yet.');
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: ((_controller.hasClients ? _controller.page ?? 0 : 0) + 1) /
                            cards.length,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${cards.length} cards'),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: cards.length,
                  onPageChanged: (_) => setState(() => reveal = false),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Card ${index + 1}/${cards.length}', style: Theme.of(context).textTheme.labelLarge),
                              const SizedBox(height: 12),
                              Text(card.title, style: Theme.of(context).textTheme.headlineSmall),
                              const Spacer(),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: reveal
                                    ? Text(
                                        card.detail,
                                        key: ValueKey('detail-$index'),
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      )
                                    : Text(
                                        l10n.reminderBanner,
                                        key: ValueKey('prompt-$index'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () => setState(() => reveal = !reveal),
                                    child: Text(reveal ? l10n.actionContinue : 'Flip'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {
                                        if (index == cards.length - 1) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Nice work! All cards reviewed.')),
                                          );
                                          return;
                                        }
                                        _controller.nextPage(
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      child: Text('I knew this'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _Flashcard {
  const _Flashcard({required this.title, required this.detail});

  final String title;
  final String detail;
}
