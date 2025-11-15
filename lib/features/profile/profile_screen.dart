import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/bookmark_providers.dart';
import '../../providers/progress_providers.dart';
import '../../providers/prefs_providers.dart';
import '../../providers/streak_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_state.dart';
import 'streak_calendar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final streakAsync = ref.watch(streakStatsProvider);
    final prefsAsync = ref.watch(userPrefsProvider);
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final progressAsync = ref.watch(overallProgressProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.achievements, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        l10n.achievementsEmpty,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    FilledButton(
                      onPressed: () => context.go('/profile/achievements'),
                      child: Text(l10n.viewAll),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => context.go('/profile/settings'),
                      child: Text(l10n.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          streakAsync.when(
            data: (stats) => AppCard(child: StreakCalendar(stats: stats)),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(message: error.toString()),
          ),
          const SizedBox(height: 24),
          progressAsync.when(
            data: (percent) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.completionRate, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: percent, minHeight: 10),
                  const SizedBox(height: 8),
                  Text(l10n.achievementProgress((percent * 100).toStringAsFixed(0))),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(message: error.toString()),
          ),
          const SizedBox(height: 24),
          prefsAsync.when(
            data: (prefs) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.dailyGoal}: ${prefs.dailyGoal}'),
                  Text('${l10n.language}: ${prefs.lang.toUpperCase()}'),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => context.go('/profile/settings'),
                    child: Text(l10n.settings),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(message: error.toString()),
          ),
          const SizedBox(height: 24),
          bookmarksAsync.when(
            data: (bookmarks) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.bookmarks, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  if (bookmarks.isEmpty)
                    Text(l10n.emptyState)
                  else
                    ...bookmarks.map((bookmark) => Text(bookmark.contentId)),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(message: error.toString()),
          ),
        ],
      ),
    );
  }
}
