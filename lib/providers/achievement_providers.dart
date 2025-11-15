import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'content_providers.dart';
import 'progress_providers.dart';
import 'streak_providers.dart';

class AchievementStatus {
  const AchievementStatus({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.progress,
    required this.unlocked,
    required this.icon,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final double progress;
  final bool unlocked;
  final String icon;
}

final achievementsProvider = FutureProvider<List<AchievementStatus>>((ref) async {
  final lessons = await ref.watch(lessonCardsProvider.future);
  final progressEntries = await ref.watch(progressEntriesProvider.future);
  final streakStats = await ref.watch(streakStatsProvider.future);

  int completedLessons = 0;
  double averageQuizScore = 0;
  if (progressEntries.isNotEmpty) {
    completedLessons = progressEntries.where((element) => element.completed).length;
    averageQuizScore = progressEntries.map((e) => e.percent).reduce((a, b) => a + b) /
        progressEntries.length;
  }
  final totalLessons = lessons.length;
  final completionRatio = totalLessons == 0 ? 0 : completedLessons / totalLessons;
  final activeDays = streakStats.days.where((element) => element.done).length;

  AchievementStatus buildAchievement({
    required String id,
    required String titleKey,
    required String descriptionKey,
    required double progress,
    required bool unlocked,
    required String icon,
  }) {
    return AchievementStatus(
      id: id,
      titleKey: titleKey,
      descriptionKey: descriptionKey,
      progress: progress.clamp(0, 1),
      unlocked: unlocked,
      icon: icon,
    );
  }

  final achievements = <AchievementStatus>[
    buildAchievement(
      id: 'first-steps',
      titleKey: 'achievement_first_steps_title',
      descriptionKey: 'achievement_first_steps_desc',
      progress: totalLessons == 0 ? 0 : completedLessons > 0 ? 1 : 0,
      unlocked: completedLessons > 0,
      icon: '🎓',
    ),
    buildAchievement(
      id: 'consistent-scholar',
      titleKey: 'achievement_consistent_scholar_title',
      descriptionKey: 'achievement_consistent_scholar_desc',
      progress: (streakStats.longest / 7).clamp(0, 1),
      unlocked: streakStats.longest >= 7,
      icon: '🔥',
    ),
    buildAchievement(
      id: 'library-explorer',
      titleKey: 'achievement_library_explorer_title',
      descriptionKey: 'achievement_library_explorer_desc',
      progress: (activeDays / 5).clamp(0, 1),
      unlocked: activeDays >= 5,
      icon: '📚',
    ),
    buildAchievement(
      id: 'quiz-ace',
      titleKey: 'achievement_quiz_ace_title',
      descriptionKey: 'achievement_quiz_ace_desc',
      progress: averageQuizScore,
      unlocked: averageQuizScore >= 0.8,
      icon: '✅',
    ),
    buildAchievement(
      id: 'course-completer',
      titleKey: 'achievement_course_completer_title',
      descriptionKey: 'achievement_course_completer_desc',
      progress: (completionRatio / 0.75).clamp(0, 1),
      unlocked: completionRatio >= 0.75,
      icon: '🏆',
    ),
  ];

  return achievements;
});
