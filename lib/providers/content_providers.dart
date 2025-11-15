import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/i18n/locale_provider.dart';
import '../data/repos/content_repo.dart';
import '../domain/services/content_service.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final contentServiceProvider = Provider<ContentService>((ref) {
  final repo = ref.watch(contentRepositoryProvider);
  return ContentService(repo);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final lessonCardsProvider = FutureProvider.autoDispose((ref) async {
  final locale = ref.watch(localeProvider)?.languageCode ?? 'en';
  final service = ref.watch(contentServiceProvider);
  return service.lessonCards(locale);
});

final bookSectionsProvider = FutureProvider.autoDispose((ref) async {
  final locale = ref.watch(localeProvider)?.languageCode ?? 'en';
  final service = ref.watch(contentServiceProvider);
  return service.bookSections(locale);
});

final searchResultsProvider = FutureProvider.autoDispose.family((ref, String query) async {
  final locale = ref.watch(localeProvider)?.languageCode ?? 'en';
  final service = ref.watch(contentServiceProvider);
  return service.search(locale, query);
});
