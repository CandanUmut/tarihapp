import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/db.dart';
import '../data/models/user_prefs.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return AppDatabase.open();
});

final userPrefsProvider = StateNotifierProvider<UserPrefsNotifier, AsyncValue<UserPrefs>>((ref) {
  return UserPrefsNotifier(ref);
});

class UserPrefsNotifier extends StateNotifier<AsyncValue<UserPrefs>> {
  UserPrefsNotifier(this._ref) : super(const AsyncLoading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final db = await _ref.read(databaseProvider.future);
    final prefs = db.loadPrefs();
    state = AsyncData(prefs);
  }

  Future<void> update(UserPrefs prefs) async {
    state = AsyncData(prefs);
    final db = await _ref.read(databaseProvider.future);
    await db.savePrefs(prefs);
  }
}
