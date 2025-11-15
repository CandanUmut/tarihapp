import '../../data/models/progress.dart';
import '../../data/repos/progress_repo.dart';

class ProgressService {
  ProgressService(this._repo);

  final ProgressRepository _repo;

  Future<void> mark({required String contentId, required double percent}) {
    return _repo.markCompleted(contentId: contentId, percent: percent);
  }

  Future<double> completionRate(int totalContent) {
    return _repo.completionRate(totalContent: totalContent);
  }

  Future<List<Progress>> allProgress() {
    return _repo.all();
  }
}
