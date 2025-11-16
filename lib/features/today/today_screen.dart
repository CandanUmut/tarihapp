import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/progress_providers.dart';
import '../../providers/streak_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/progress_ring.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overallAsync = ref.watch(overallProgressProvider);
    final streakAsync = ref.watch(streakStatsProvider);
    final dueAsync = ref.watch(flashcardsDueCountProvider);

    final overall = overallAsync.maybeWhen(data: (value) => value, orElse: () => 0.0);
    final due = dueAsync.maybeWhen(data: (value) => value, orElse: () => 0);
    final streak = streakAsync.maybeWhen(data: (value) => value, orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProgressHeader(overall: overall, streakLabel: streak != null ? l10n.streakDays(streak.days) : '--'),
          const SizedBox(height: 12),
          _ContinueCard(label: l10n.action_continue, onTap: () => context.go('/lessons')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _TodayTile(title: l10n.lessons, subtitle: l10n.todayLearn, icon: Icons.menu_book, onTap: () => context.go('/lessons'))),
              const SizedBox(width: 12),
              Expanded(child: _TodayTile(title: l10n.flashcards, subtitle: l10n.todayReview(due), icon: Icons.bolt, onTap: () => context.go('/flashcards'))),
              const SizedBox(width: 12),
              Expanded(child: _TodayTile(title: l10n.todayReflect, subtitle: l10n.reminderBanner, icon: Icons.edit_note, onTap: () => context.go('/research'))),
            ],
          ),
          const SizedBox(height: 12),
          _QuickLinksRow(l10n: l10n),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.overall, required this.streakLabel});

  final double overall;
  final String streakLabel;

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
                  AppLocalizations.of(context).completionRate,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(streakLabel, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context).continueLearning),
            ],
          ),
          const Icon(Icons.play_arrow_rounded),
        ],
      ),
    );
  }
}

class _TodayTile extends StatelessWidget {
  const _TodayTile({required this.title, required this.subtitle, required this.icon, this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _QuickLinksRow extends StatelessWidget {
  const _QuickLinksRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        PillButton(label: l10n.explore, icon: Icons.explore, onTap: () => context.go('/explore')),
        PillButton(label: l10n.history, icon: Icons.timeline, onTap: () => context.go('/history')),
        PillButton(label: l10n.research, icon: Icons.science, onTap: () => context.go('/research')),
        PillButton(label: l10n.profile, icon: Icons.person, onTap: () => context.go('/profile')),
      ],
    );
  }
}
