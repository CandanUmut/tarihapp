import '../../models/bookmark.dart';
import '../db.dart';

class BookmarkDao {
  BookmarkDao(this._db);

  final AppDatabase _db;

  Future<List<Bookmark>> fetchBookmarks() async {
    return _db.getBookmarks();
  }

  Future<void> toggle(Bookmark bookmark) {
    return _db.toggleBookmark(bookmark);
  }
}
