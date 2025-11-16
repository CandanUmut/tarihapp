import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/dao/streak_dao.dart';
import '../data/models/streak.dart';
import '../data/repos/streak_repo.dart';
import 'prefs_providers.dart';

final streakDaoProvider = FutureProvider<StreakDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return StreakDao(db);
});

final streakRepositoryProvider = FutureProvider<StreakRepository>((ref) async {
  final dao = await ref.watch(streakDaoProvider.future);
  return StreakRepository(dao);
});

final streakControllerProvider = AsyncNotifierProvider<StreakController, StreakStats>(StreakController.new);

class StreakController extends AsyncNotifier<StreakStats> {
  late StreakRepository _repo;

  @override
  Future<StreakStats> build() async {
    _repo = await ref.watch(streakRepositoryProvider.future);
    return _repo.fetchStats();
  }

  Future<void> markTodayDone() async {
    await _repo.markTodayDone();
    state = const AsyncLoading();
    final updated = await _repo.fetchStats();
    state = AsyncData(updated);
  }
}

final streakStatsProvider = Provider<AsyncValue<StreakStats>>((ref) {
  return ref.watch(streakControllerProvider);
});
