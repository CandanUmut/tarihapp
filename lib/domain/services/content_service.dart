import '../../data/models/lesson_card.dart';
import '../../core/utils/markdown_utils.dart';
import '../../data/repos/content_repo.dart';

class ContentService {
  ContentService(this._repo);

  final ContentRepository _repo;

  Future<List<LessonCard>> lessonCards(String lang) {
    return _repo.loadLessonCards(lang);
  }

  Future<List<MarkdownSection>> bookSections(String lang) {
    return _repo.loadBookSections(lang);
  }

  Future<List<LessonCard>> search(String lang, String query) {
    return _repo.search(lang, query);
  }
}
