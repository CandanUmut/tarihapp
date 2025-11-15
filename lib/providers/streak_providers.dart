import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/dao/streak_dao.dart';
import '../data/models/streak.dart';
import '../data/repos/streak_repo.dart';
import '../domain/services/streak_service.dart';
import 'prefs_providers.dart';

final streakDaoProvider = FutureProvider<StreakDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return StreakDao(db);
});

final streakRepositoryProvider = FutureProvider<StreakRepository>((ref) async {
  final dao = await ref.watch(streakDaoProvider.future);
  return StreakRepository(dao);
});

final streakServiceProvider = FutureProvider<StreakService>((ref) async {
  final repo = await ref.watch(streakRepositoryProvider.future);
  return StreakService(repo);
});

final streakStatsProvider = FutureProvider<StreakStats>((ref) async {
  final service = await ref.watch(streakServiceProvider.future);
  return service.stats();
});
