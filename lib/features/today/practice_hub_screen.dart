import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/progress_providers.dart';
import '../../providers/streak_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/progress_ring.dart';

class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overallAsync = ref.watch(overallProgressProvider);
    final streakAsync = ref.watch(streakStatsProvider);
    final dueAsync = ref.watch(flashcardsDueCountProvider);

    final overall = overallAsync.maybeWhen(data: (value) => value, orElse: () => 0.0);
    final streak = streakAsync.maybeWhen(data: (value) => value, orElse: () => null);
    final due = dueAsync.maybeWhen(data: (value) => value, orElse: () => 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.practiceHubTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/profile/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProgressHeader(
            l10n: l10n,
            overall: overall,
            streakLabel: streak != null ? l10n.streakDays(streak.longest) : '--',
            currentStreak: streak?.current ?? 0,
          ),
          const SizedBox(height: 16),
          Text(l10n.practiceHubSubtitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PracticeTile(
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.flash_on,
                title: l10n.flashcards,
                subtitle: l10n.practiceFlashcards(due),
                onTap: () => context.go('/flashcards'),
              ),
              _PracticeTile(
                color: Colors.orange,
                icon: Icons.quiz_outlined,
                title: l10n.practiceQuiz,
                subtitle: l10n.practiceQuizSubtitle,
                onTap: () => context.go('/lessons'),
              ),
              _PracticeTile(
                color: Colors.teal,
                icon: Icons.menu_book_rounded,
                title: l10n.readNow,
                subtitle: l10n.practiceResearch,
                onTap: () => context.go('/research'),
              ),
              _PracticeTile(
                color: Colors.purple,
                icon: Icons.map,
                title: l10n.history,
                subtitle: l10n.practiceTimeline,
                onTap: () => context.go('/history'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined),
                    const SizedBox(width: 8),
                    Text(l10n.practiceKeepGoing, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.practiceKeepGoingSubtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    PillButton(
                      label: l10n.actionContinue,
                      icon: Icons.play_arrow_rounded,
                      onTap: () => context.go('/lessons'),
                    ),
                    PillButton(
                      label: l10n.explore,
                      icon: Icons.public,
                      variant: PillButtonVariant.secondary,
                      onTap: () => context.go('/explore'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.l10n,
    required this.overall,
    required this.streakLabel,
    required this.currentStreak,
  });

  final AppLocalizations l10n;
  final double overall;
  final String streakLabel;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ProgressRing(
            value: overall,
            label: '${(overall * 100).toStringAsFixed(0)}%',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.practiceHeroHeadline,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  streakLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(l10n.practiceCurrentStreak(currentStreak)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: AppCard(
        onTap: onTap,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
