import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/dao/bookmark_dao.dart';
import '../data/models/bookmark.dart';
import '../data/repos/bookmark_repo.dart';
import 'prefs_providers.dart';

final bookmarkDaoProvider = FutureProvider<BookmarkDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return BookmarkDao(db);
});

final bookmarkRepositoryProvider = FutureProvider<BookmarkRepository>((ref) async {
  final dao = await ref.watch(bookmarkDaoProvider.future);
  return BookmarkRepository(dao);
});

final bookmarksProvider = FutureProvider<List<Bookmark>>((ref) async {
  final repo = await ref.watch(bookmarkRepositoryProvider.future);
  return repo.fetch();
});

final bookmarkToggleProvider = Provider((ref) => (String contentId) async {
  final repo = await ref.watch(bookmarkRepositoryProvider.future);
  await repo.toggleBookmark(contentId);
  ref.invalidate(bookmarksProvider);
});
