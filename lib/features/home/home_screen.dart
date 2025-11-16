import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/markdown_utils.dart';
import '../../data/models/lesson_card.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/achievement_providers.dart';
import '../../providers/content_providers.dart';
import '../../providers/progress_providers.dart';
import '../../providers/streak_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progressAsync = ref.watch(overallProgressProvider);
    final streakAsync = ref.watch(streakStatsProvider);
    final lessonsAsync = ref.watch(lessonCardsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final bookSectionsAsync = ref.watch(bookSectionsProvider);

    final streak = streakAsync.valueOrNull;
    final progressValue = progressAsync.valueOrNull ?? 0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(overallProgressProvider);
          ref.invalidate(lessonCardsProvider);
          ref.invalidate(bookSectionsProvider);
          await ref.read(progressControllerProvider.notifier).refresh();
          ref.invalidate(streakControllerProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: _HeroHeader(
                greeting: l10n.homeGreeting,
                streakLabel: streak != null ? l10n.streakDays(streak.current) : l10n.today,
                progressLabel: l10n.completionRate,
                progressValue: progressValue,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  lessonsAsync.when(
                    data: (lessons) {
                      if (lessons.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: l10n.continueLearning,
                            subtitle: 'Pick up the next lesson or jump into practice.',
                            action: TextButton(
                              onPressed: () => context.go('/lessons'),
                              child: Text(l10n.viewAll),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DailyFocusCard(lesson: lessons.first),
                        ],
                      );
                    },
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    )),
                    error: (error, _) => Text(error.toString()),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: l10n.practiceHubTitle,
                    subtitle: l10n.practiceHubSubtitle,
                    action: TextButton(
                      onPressed: () => context.go('/practice'),
                      child: Text(l10n.practiceQuiz),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionGrid(
                    actions: [
                      _QuickAction(
                        label: l10n.lessons,
                        icon: Icons.menu_book,
                        onTap: () => context.go('/lessons'),
                      ),
                      _QuickAction(
                        label: l10n.flashcards,
                        icon: Icons.bolt,
                        onTap: () => context.go('/flashcards'),
                      ),
                      _QuickAction(
                        label: l10n.practiceHubTitle,
                        icon: Icons.task_alt,
                        onTap: () => context.go('/practice'),
                      ),
                      _QuickAction(
                        label: l10n.explore,
                        icon: Icons.explore,
                        onTap: () => context.go('/explore'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  progressAsync.when(
                    data: (value) => AppCard(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.overallProgress, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: value, minHeight: 10),
                          const SizedBox(height: 8),
                          Text(l10n.achievementProgress((value * 100).toStringAsFixed(0))),
                        ],
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text(error.toString()),
                  ),
                  const SizedBox(height: 20),
                  achievementsAsync.when(
                    data: (items) => _AchievementsStrip(items: items.take(3).toList()),
                    loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                    error: (error, _) => Text(error.toString()),
                  ),
                  const SizedBox(height: 20),
                  lessonsAsync.when(
                    data: (lessons) => _RecommendedLessonsCarousel(lessons: lessons.take(5).toList()),
                    loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                    error: (error, _) => Text(error.toString()),
                  ),
                  const SizedBox(height: 20),
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
                            subtitle: 'Short selections from foundational texts.',
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
                    loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
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

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.streakLabel,
    required this.progressLabel,
    required this.progressValue,
  });

  final String greeting;
  final String streakLabel;
  final String progressLabel;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        streakLabel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => GoRouter.of(context).go('/profile/settings'),
                  icon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
                  tooltip: AppLocalizations.of(context).settings,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              background: theme.colorScheme.onPrimary.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progressLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 10,
                          backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.onPrimary,
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    onPressed: () => GoRouter.of(context).go('/practice'),
                    child: Text(AppLocalizations.of(context).actionContinue),
                  ),
                ],
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

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        final tileWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: actions
              .map(
                (action) => SizedBox(
                  width: tileWidth,
                  child: AppCard(
                    onTap: action.onTap,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(action.icon, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(action.label, style: Theme.of(context).textTheme.titleMedium),
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

class _QuickAction {
  const _QuickAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _RecommendedLessonsCarousel extends StatelessWidget {
  const _RecommendedLessonsCarousel({required this.lessons});

  final List<LessonCard> lessons;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recommended next steps',
          subtitle: 'Curated picks based on trending interests and your streak.',
        ),
        const SizedBox(height: 12),
        SizedBox(
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
        ),
      ],
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

class _AchievementsStrip extends StatelessWidget {
  const _AchievementsStrip({required this.items});

  final List<AchievementStatus> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppLocalizations.of(context).achievements,
          subtitle: 'Badges update in real time as you study.',
          action: TextButton(
            onPressed: () => GoRouter.of(context).go('/profile/achievements'),
            child: Text(AppLocalizations.of(context).viewAll),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalizations.of(context).raw(item.titleKey),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context).raw(item.descriptionKey),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: item.progress, minHeight: 6),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}
