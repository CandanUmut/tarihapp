import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_prefs.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/history/history_timeline_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/lessons/flashcard_flow.dart';
import '../../features/lessons/lesson_detail_screen.dart';
import '../../features/lessons/lesson_list_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/achievements_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/research/research_reader_screen.dart';
import '../../providers/prefs_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/today',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/today',
        builder: (context, state) => const TodayScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'lessons',
            builder: (context, state) => const LessonListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => LessonDetailScreen(
                  lessonId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const HistoryTimelineScreen(),
          ),
          GoRoute(
            path: 'research',
            builder: (context, state) => const ResearchReaderScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'achievements',
                builder: (context, state) => const AchievementsScreen(),
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'flashcards',
            builder: (context, state) => const FlashcardFlow(),
          ),
        ],
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<AsyncValue<UserPrefs>>(userPrefsProvider, (_, __) => notifyListeners());
  }

  final Ref ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final prefs = ref.read(userPrefsProvider);
    return prefs.whenOrNull(
      data: (value) {
        if (!value.onboardingDone && state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        if (value.onboardingDone && state.matchedLocation == '/onboarding') {
          return '/today';
        }
        return null;
      },
    );
  }
}
