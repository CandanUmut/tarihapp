import '../../models/section.dart';

class LessonDao {
  const LessonDao();

  Future<List<Section>> fetchSections(String lessonId) async {
    // Sections are derived from markdown at runtime; see ContentService.
    return <Section>[];
  }
}
