import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lesson_card.dart';
import '../../providers/bookmark_providers.dart';
import '../../providers/content_providers.dart';
import '../../providers/progress_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_state.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/section_header.dart';

class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCards = ref.watch(lessonCardsProvider);
    return asyncCards.when(
      data: (lessons) {
        final lessonIndex = lessons.indexWhere((element) => element.id == lessonId);
        if (lessonIndex == -1) {
          return const Scaffold(
            body: ErrorState(message: 'This lesson could not be found.'),
          );
        }
        final lesson = lessons[lessonIndex];
        final theme = Theme.of(context);
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.85),
                            theme.colorScheme.secondary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.tradition,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lesson.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const Spacer(),
                            Wrap(
                              spacing: 12,
                              children: [
                                Chip(
                                  label: Text(lesson.level.toUpperCase()),
                                  backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                                ),
                                ...lesson.tags
                                    .take(3)
                                    .map(
                                      (tag) => Chip(
                                        label: Text(tag),
                                        backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                                      ),
                                    )
                                    .toList(growable: false),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SectionHeader(
                        title: 'Lesson overview',
                        subtitle: 'Key context before you dive into the source texts.',
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lesson.summary, style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(
                                  avatar: const Icon(Icons.school, size: 16),
                                  label: Text('Level: ${lesson.level}'),
                                ),
                                Chip(
                                  avatar: const Icon(Icons.people_alt, size: 16),
                                  label: Text('Tradition: ${lesson.tradition}'),
                                ),
                                Chip(
                                  avatar: const Icon(Icons.menu_book, size: 16),
                                  label: Text('${lesson.coreTexts.length} core texts'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Key takeaways',
                        subtitle: 'Review the essential ideas distilled from this lesson.',
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          children: lesson.keyPoints
                              .map(
                                (point) => ListTile(
                                  leading: const Icon(Icons.check_circle_outline),
                                  title: Text(point),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Discussion prompts',
                        subtitle: 'Use these to spark reflections or group conversation.',
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          children: lesson.discussionQuestions
                              .map(
                                (question) => ListTile(
                                  leading: const Icon(Icons.forum_outlined),
                                  title: Text(question),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Primary sources',
                        subtitle: 'Authentic references to verify and expand your understanding.',
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: MarkdownBody(data: lesson.coreTexts.join('\n\n')),
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: 'Study tools',
                        subtitle: 'Mark progress, save for later, or test your knowledge.',
                      ),
                      const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              PillButton(
                                label: 'Mark done',
                                onPressed: () async {
                                  await ref
                                      .read(progressControllerProvider.notifier)
                                      .mark(contentId: lesson.id, percent: 1);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Marked as completed')),
                                    );
                                  }
                                },
                              ),
                              PillButton(
                                label: 'Bookmark',
                                variant: PillButtonVariant.secondary,
                            onPressed: () async {
                              final toggle = ref.read(bookmarkToggleProvider);
                              await toggle(lesson.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bookmark updated')),
                                );
                              }
                            },
                              ),
                              PillButton(
                                label: 'Take quiz',
                                variant: PillButtonVariant.secondary,
                                onPressed: () => GoRouter.of(context).go('/lessons/${lesson.id}/quiz'),
                              ),
                            ],
                          ),
                        ]),
                      ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: ErrorState(message: error.toString())),
    );
  }
}
