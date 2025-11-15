import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bookmark.dart';
import '../models/progress.dart';
import '../models/streak.dart';
import '../models/user_prefs.dart';

class AppDatabase {
  AppDatabase(this._prefs);

  final SharedPreferences _prefs;

  static const _progressKey = 'progress_records';
  static const _streakKey = 'streak_records';
  static const _prefsKey = 'user_prefs';
  static const _bookmarkKey = 'bookmarks';

  static Future<AppDatabase> open() async {
    final prefs = await SharedPreferences.getInstance();
    return AppDatabase(prefs);
  }

  List<Progress> getProgress() {
    final data = _prefs.getStringList(_progressKey) ?? <String>[];
    return data
        .map((e) => Progress.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> upsertProgress(Progress progress) async {
    final items = getProgress();
    final updated = <Progress>[];
    var found = false;
    for (final item in items) {
      if (item.id == progress.id) {
        updated.add(progress);
        found = true;
      } else {
        updated.add(item);
      }
    }
    if (!found) {
      updated.add(progress);
    }
    await _prefs.setStringList(
      _progressKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(growable: false),
    );
  }

  List<StreakDay> getStreakDays() {
    final data = _prefs.getStringList(_streakKey) ?? <String>[];
    return data
        .map((e) => StreakDay.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> saveStreakDays(List<StreakDay> days) async {
    await _prefs.setStringList(
      _streakKey,
      days.map((e) => jsonEncode(e.toJson())).toList(growable: false),
    );
  }

  List<Bookmark> getBookmarks() {
    final data = _prefs.getStringList(_bookmarkKey) ?? <String>[];
    return data
        .map((e) => Bookmark.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final current = getBookmarks();
    if (current.any((element) => element.id == bookmark.id)) {
      final filtered =
          current.where((element) => element.id != bookmark.id).toList();
      await _prefs.setStringList(
        _bookmarkKey,
        filtered.map((e) => jsonEncode(e.toJson())).toList(growable: false),
      );
      return;
    }
    final updated = [...current, bookmark];
    await _prefs.setStringList(
      _bookmarkKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(growable: false),
    );
  }

  UserPrefs loadPrefs() {
    final data = _prefs.getString(_prefsKey);
    if (data == null) {
      return UserPrefs.defaultPrefs;
    }
    return UserPrefs.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> savePrefs(UserPrefs prefs) async {
    await _prefs.setString(_prefsKey, jsonEncode(prefs.toJson()));
  }
}
