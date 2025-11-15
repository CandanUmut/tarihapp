import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/utils/markdown_utils.dart';
import '../models/lesson_card.dart';

class ContentRepository {
  ContentRepository();

  final Map<String, List<LessonCard>> _lessonCache = {};
  final Map<String, List<MarkdownSection>> _bookCache = {};

  Future<List<LessonCard>> loadLessonCards(String lang) async {
    if (_lessonCache.containsKey(lang)) {
      return _lessonCache[lang]!;
    }
    final raw = await rootBundle
        .loadString('assets/content/$lang/cards/lesson_cards.json');
    final data = jsonDecode(raw) as List<dynamic>;
    final cards = data
        .map((e) => LessonCard.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _lessonCache[lang] = cards;
    return cards;
  }

  Future<List<MarkdownSection>> loadBookSections(String lang) async {
    if (_bookCache.containsKey(lang)) {
      return _bookCache[lang]!;
    }
    final files = _bookFiles[lang] ?? const <String>[];
    final sections = <MarkdownSection>[];
    for (final file in files) {
      final text = await rootBundle.loadString(file);
      sections.addAll(MarkdownUtils.splitByHeading(text));
    }
    _bookCache[lang] = sections;
    return sections;
  }

  Future<List<LessonCard>> search(String lang, String query) async {
    final cards = await loadLessonCards(lang);
    if (query.trim().isEmpty) {
      return cards;
    }
    final lower = query.toLowerCase();
    return cards
        .where(
          (card) =>
              card.title.toLowerCase().contains(lower) ||
              card.summary.toLowerCase().contains(lower) ||
              card.tags.any((tag) => tag.toLowerCase().contains(lower)) ||
              card.keyPoints.any((kp) => kp.toLowerCase().contains(lower)),
        )
        .toList(growable: false);
  }

  static const Map<String, List<String>> _bookFiles = {
    'en': [
      'assets/content/en/book/part1_foundations.md',
      'assets/content/en/book/part2_prophets.md',
      'assets/content/en/book/part3_civilizations.md',
    ],
    'tr': [
      'assets/content/tr/book/part1_temeller.md',
      'assets/content/tr/book/part2_peygamberler.md',
      'assets/content/tr/book/part3_medeniyetler.md',
    ],
  };
}
