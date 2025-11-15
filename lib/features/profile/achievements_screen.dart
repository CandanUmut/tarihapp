import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/achievement_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_state.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final achievementsAsync = ref.watch(achievementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievements)),
      body: achievementsAsync.when(
        data: (achievements) {
          if (achievements.isEmpty) {
            return Center(child: Text(l10n.achievementsEmpty));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = achievements[index];
              final unlocked = item.unlocked;
              final progressPercent = (item.progress * 100).clamp(0, 100).toStringAsFixed(0);
              final title = l10n.translateKey(item.titleKey);
              final description = l10n.translateKey(item.descriptionKey);
              return AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Chip(
                          label: Text(unlocked ? l10n.achievementUnlocked : l10n.achievementLocked),
                          backgroundColor: unlocked
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: item.progress.clamp(0, 1),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.achievementProgress(progressPercent)),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(message: error.toString()),
      ),
    );
  }
}
