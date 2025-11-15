// In-memory tables backed by SharedPreferences (see db.dart).
// This file documents the expected schema for future Drift migration.
class LessonTableFields {
  static const id = 'id';
  static const title = 'title';
  static const level = 'level';
  static const lang = 'lang';
  static const tags = 'tags';
  static const summary = 'summary';
}

class SectionTableFields {
  static const id = 'id';
  static const lessonId = 'lessonId';
  static const orderNo = 'orderNo';
  static const heading = 'heading';
  static const bodyMarkdown = 'bodyMarkdown';
}

class ProgressTableFields {
  static const id = 'id';
  static const contentId = 'contentId';
  static const completed = 'completed';
  static const percent = 'percent';
  static const updatedAt = 'updatedAt';
}

class StreakTableFields {
  static const id = 'id';
  static const date = 'date';
  static const done = 'done';
}

class BookmarkTableFields {
  static const id = 'id';
  static const contentId = 'contentId';
  static const createdAt = 'createdAt';
}

class UserPrefsTableFields {
  static const id = 'id';
  static const lang = 'lang';
  static const dailyGoal = 'dailyGoal';
  static const onboardingDone = 'onboardingDone';
}
