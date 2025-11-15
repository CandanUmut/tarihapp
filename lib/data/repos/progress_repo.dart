import '../../core/utils/date_utils.dart';
import '../local/dao/progress_dao.dart';
import '../models/progress.dart';

class ProgressRepository {
  ProgressRepository(this._dao);

  final ProgressDao _dao;

  Future<List<Progress>> all() {
    return _dao.fetchAll();
  }

  Future<double> completionRate({required int totalContent}) async {
    final items = await _dao.fetchAll();
    if (items.isEmpty || totalContent <= 0) {
      return 0;
    }
    final sum = items.fold<double>(0, (value, element) => value + element.percent);
    final denominator = totalContent > items.length ? totalContent : items.length;
    final ratio = sum / denominator;
    return ratio.clamp(0, 1);
  }

  Future<Progress?> getByContent(String contentId) async {
    final items = await _dao.fetchAll();
    final i = items.indexWhere((e) => e.contentId == contentId);
    return i == -1 ? null : items[i];
  }

  Future<void> markCompleted({
    required String contentId,
    required double percent,
  }) async {
    final id = 'progress-$contentId';
    final record = Progress(
      id: id,
      contentId: contentId,
      completed: percent >= 1,
      percent: percent.clamp(0, 1),
      updatedAt: AppDateUtils.encodeDate(DateTime.now()),
    );
    await _dao.save(record);
  }
}
