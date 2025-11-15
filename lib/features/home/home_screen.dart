import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/markdown_utils.dart';
import '../../data/models/lesson_card.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/content_providers.dart';
import '../../providers/progress_providers.dart';
import '../../providers/streak_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';
import 'home_header.dart';
import 'progress_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progressAsync = ref.watch(overallProgressProvider);
    final streakAsync = ref.watch(streakStatsProvider);
    final lessonsAsync = ref.watch(lessonCardsProvider);

    final bookSectionsAsync = ref.watch(bookSectionsProvider);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(overallProgressProvider);
          ref.invalidate(streakStatsProvider);
          ref.invalidate(lessonCardsProvider);
          ref.invalidate(bookSectionsProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              titleSpacing: 24,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text(l10n.appTitle),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  HomeHeader(
                    greeting: l10n.homeGreeting,
                    streakAsync: streakAsync,
                    streakLabelBuilder: (days) => l10n.streakDays(days),
                  ),
                  const SizedBox(height: 24),
                  progressAsync.when(
                    data: (percent) => ProgressHeader(
                      percent: percent,
                      label: l10n.completionRate,
                    ),
                    loading: () => const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text(error.toString()),
                  ),
                  const SizedBox(height: 24),
                  lessonsAsync.when(
                    data: (lessons) {
                      if (lessons.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final total = lessons.length;
                      final beginnerCount = lessons.where((l) => l.level.toLowerCase() == 'beginner').length;
                      final intermediateCount = lessons.where((l) => l.level.toLowerCase() == 'intermediate').length;
                      final popularTags = _popularTags(lessons);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: l10n.continueLearning,
                            subtitle: 'You have $total structured lessons — $beginnerCount beginner and $intermediateCount intermediate modules ready to explore.',
                            action: TextButton(
                              onPressed: () => context.go('/lessons'),
                              child: Text(l10n.viewAll),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DailyFocusCard(lesson: lessons.first),
                          const SizedBox(height: 16),
                          _QuickStatsRow(
                            lessons: lessons,
                            popularTags: popularTags,
                            onSeeAll: () => context.go('/lessons'),
                          ),
                          const SizedBox(height: 24),
                          SectionHeader(
                            title: 'Recommended next steps',
                            subtitle: 'Curated picks based on trending interests and your current streak.',
                          ),
                          const SizedBox(height: 12),
                          _RecommendedLessonsCarousel(lessons: lessons.take(6).toList()),
                        ],
                      );
                    },
                    loading: () => const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text(error.toString()),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: l10n.explore,
                    subtitle: 'Navigate to other study spaces and tools.',
                  ),
                  const SizedBox(height: 12),
                  _QuickLinkGrid(
                    links: [
                      _QuickLinkData(
                        label: l10n.lessons,
                        icon: Icons.menu_book,
                        description: 'Browse structured modules with summaries and quizzes.',
                        onTap: () => context.go('/lessons'),
                      ),
                      _QuickLinkData(
                        label: l10n.history,
                        icon: Icons.timeline,
                        description: 'Timeline views to place events in context.',
                        onTap: () => context.go('/history'),
                      ),
                      _QuickLinkData(
                        label: l10n.research,
                        icon: Icons.science,
                        description: 'Read curated academic references and excerpts.',
                        onTap: () => context.go('/research'),
                      ),
                      _QuickLinkData(
                        label: l10n.flashcards,
                        icon: Icons.bolt,
                        description: 'Quick reviews to reinforce key concepts.',
                        onTap: () => context.go('/flashcards'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  bookSectionsAsync.when(
                    data: (sections) {
                      if (sections.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'From the study library',
                            subtitle: 'Short selections from foundational texts to deepen context.',
                            action: TextButton(
                              onPressed: () => context.go('/research'),
                              child: const Text('Open library'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...sections.take(2).map((section) => _LibraryExcerpt(section: section)),
                        ],
                      );
                    },
                    loading: () => const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text(error.toString()),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyFocusCard extends StatelessWidget {
  const _DailyFocusCard({required this.lesson});

  final LessonCard lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () => GoRouter.of(context).go('/lessons/${lesson.id}'),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withOpacity(0.12),
          theme.colorScheme.secondary.withOpacity(0.12),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Focus of the day', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            lesson.title,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            lesson.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(lesson.level.toUpperCase())),
              Chip(label: Text(lesson.tradition)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.lessons,
    required this.popularTags,
    required this.onSeeAll,
  });

  final List<LessonCard> lessons;
  final List<String> popularTags;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final totalQuiz = lessons.fold<int>(0, (acc, lesson) => acc + lesson.quiz.length);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final children = [
          _StatTile(
            icon: Icons.auto_stories,
            title: 'Lessons ready',
            value: '${lessons.length}',
            subtitle: 'Curated learning modules',
          ),
          _StatTile(
            icon: Icons.quiz,
            title: 'Practice questions',
            value: '$totalQuiz',
            subtitle: 'Self-check quizzes',
          ),
          _StatTile(
            icon: Icons.local_offer,
            title: 'Popular topics',
            value: popularTags.join(', '),
            subtitle: 'Tap explore to dive deeper',
          ),
          AppCard(
            onTap: onSeeAll,
            child: Row(
              children: [
                Icon(Icons.play_circle, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Continue where you left off',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children
              .map(
                (child) => SizedBox(
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                  child: child,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkGrid extends StatelessWidget {
  const _QuickLinkGrid({required this.links});

  final List<_QuickLinkData> links;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final tileWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: links
              .map(
                (link) => SizedBox(
                  width: tileWidth,
                  child: AppCard(
                    onTap: link.onTap,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(link.icon, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(link.label, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                link.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _QuickLinkData {
  const _QuickLinkData({
    required this.label,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String description;
  final VoidCallback onTap;
}

class _RecommendedLessonsCarousel extends StatelessWidget {
  const _RecommendedLessonsCarousel({required this.lessons});

  final List<LessonCard> lessons;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lessons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return SizedBox(
            width: 280,
            child: AppCard(
              onTap: () => GoRouter.of(context).go('/lessons/${lesson.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    lesson.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    children: lesson.tags
                        .take(3)
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LibraryExcerpt extends StatelessWidget {
  const _LibraryExcerpt({required this.section});

  final MarkdownSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.heading, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              section.body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _popularTags(List<LessonCard> lessons) {
  final counts = <String, int>{};
  for (final lesson in lessons) {
    for (final tag in lesson.tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(3).map((e) => e.key).toList(growable: false);
}
