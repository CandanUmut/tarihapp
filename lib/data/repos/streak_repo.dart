import '../../core/utils/date_utils.dart';
import '../local/dao/streak_dao.dart';
import '../models/streak.dart';

class StreakRepository {
  StreakRepository(this._dao);

  final StreakDao _dao;

  Future<StreakStats> fetchStats() async {
    final days = await _dao.fetchDays();
    var current = 0;
    var longest = 0;
    StreakDay? prev;
    for (final day in days.where((element) => element.done)) {
      if (prev != null && _isConsecutive(prev!.date, day.date)) {
        current += 1;
      } else {
        current = 1;
      }
      if (current > longest) {
        longest = current;
      }
      prev = day;
    }
    return StreakStats(current: current, longest: longest, days: days);
  }

  Future<void> toggleToday() async {
    final today = AppDateUtils.encodeDate(DateTime.now());
    final days = await _dao.fetchDays();
    final existingIndex = days.indexWhere((element) => element.date == today);
    if (existingIndex >= 0) {
      final updated = List<StreakDay>.from(days);
      final current = updated[existingIndex];
      updated[existingIndex] = StreakDay(date: current.date, done: !current.done);
      await _dao.saveDays(updated);
      return;
    }
    await _dao.saveDays([
      ...days,
      StreakDay(date: today, done: true),
    ]);
  }

  bool _isConsecutive(int prev, int current) {
    final prevDate = AppDateUtils.decodeDate(prev);
    final currDate = AppDateUtils.decodeDate(current);
    final diff = currDate.difference(prevDate).inDays;
    return diff == 1;
  }
}
