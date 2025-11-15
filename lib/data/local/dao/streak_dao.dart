import '../../models/streak.dart';
import '../db.dart';

class StreakDao {
  StreakDao(this._db);

  final AppDatabase _db;

  Future<List<StreakDay>> fetchDays() async {
    return _db.getStreakDays();
  }

  Future<void> saveDays(List<StreakDay> days) {
    return _db.saveStreakDays(days);
  }
}
