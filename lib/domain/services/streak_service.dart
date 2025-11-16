import '../../data/models/streak.dart';
import '../../data/repos/streak_repo.dart';

class StreakService {
  StreakService(this._repo);

  final StreakRepository _repo;

  Future<StreakStats> stats() {
    return _repo.fetchStats();
  }

  Future<void> toggleToday() {
    return _repo.toggleToday();
  }

  Future<void> markTodayDone() {
    return _repo.markTodayDone();
  }
}
