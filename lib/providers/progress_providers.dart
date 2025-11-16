import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/dao/progress_dao.dart';
import '../data/models/progress.dart';
import '../data/repos/progress_repo.dart';
import 'content_providers.dart';
import 'prefs_providers.dart';
import 'streak_providers.dart';

final progressDaoProvider = FutureProvider<ProgressDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return ProgressDao(db);
});

final progressRepositoryProvider = FutureProvider<ProgressRepository>((ref) async {
  final dao = await ref.watch(progressDaoProvider.future);
  return ProgressRepository(dao);
});

/// Notifier that keeps progress in memory so achievements and streaks update in real time.
final progressControllerProvider = AsyncNotifierProvider<ProgressController, List<Progress>>(ProgressController.new);

class ProgressController extends AsyncNotifier<List<Progress>> {
  late ProgressRepository _repo;

  @override
  Future<List<Progress>> build() async {
    _repo = await ref.watch(progressRepositoryProvider.future);
    return _repo.all();
  }

  Future<void> mark({required String contentId, required double percent}) async {
    await _repo.markCompleted(contentId: contentId, percent: percent);
    state = const AsyncLoading();
    final updated = await _repo.all();
    state = AsyncData(updated);
    // Keep the streak in sync whenever the learner completes something.
    await ref.read(streakControllerProvider.notifier).markTodayDone();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final updated = await _repo.all();
    state = AsyncData(updated);
  }

  double completionRate(int totalContent) {
    final items = state.valueOrNull ?? [];
    if (items.isEmpty || totalContent <= 0) {
      return 0;
    }
    final sum = items.fold<double>(0, (value, element) => value + element.percent);
    final denominator = totalContent > items.length ? totalContent : items.length;
    final ratio = sum / denominator;
    return ratio.clamp(0, 1);
  }
}

final overallProgressProvider = Provider<AsyncValue<double>>((ref) {
  final lessons = ref.watch(lessonCardsProvider);
  final progress = ref.watch(progressControllerProvider);

  return lessons.when(
    data: (lessonCards) {
      return progress.when(
        data: (entries) {
          if (lessonCards.isEmpty || entries.isEmpty) {
            return const AsyncValue.data(0);
          }
          final controller = ref.read(progressControllerProvider.notifier);
          return AsyncValue.data(controller.completionRate(lessonCards.length));
        },
        loading: AsyncValue.loading,
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    },
    loading: AsyncValue.loading,
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Count of flashcards due today; placeholder stream until SRS is wired.
final flashcardsDueCountProvider = StreamProvider<int>((ref) async* {
  // Existing implementation will replace this placeholder. Keeping a stream so
  // the UI remains reactive when the underlying repo is connected.
  yield 0;
});
