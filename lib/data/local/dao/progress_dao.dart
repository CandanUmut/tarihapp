import '../../models/progress.dart';
import '../db.dart';

class ProgressDao {
  ProgressDao(this._db);

  final AppDatabase _db;

  Future<List<Progress>> fetchAll() async {
    return _db.getProgress();
  }

  Future<void> save(Progress progress) {
    return _db.upsertProgress(progress);
  }
}
