import '../local/dao/bookmark_dao.dart';
import '../models/bookmark.dart';

class BookmarkRepository {
  BookmarkRepository(this._dao);

  final BookmarkDao _dao;

  Future<List<Bookmark>> fetch() {
    return _dao.fetchBookmarks();
  }

  Future<void> toggleBookmark(String contentId) async {
    final bookmark = Bookmark(
      id: 'bookmark-$contentId',
      contentId: contentId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _dao.toggle(bookmark);
  }
}
