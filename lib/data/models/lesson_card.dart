import 'dart:convert';

class QuizMcq {
  const QuizMcq({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizMcq.fromJson(Map<String, dynamic> json) {
    return QuizMcq(
      question: json['q'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      answer: json['answer'] as String,
    );
  }

  final String question;
  final List<String> options;
  final String answer;

  Map<String, dynamic> toJson() => {
        'q': question,
        'options': options,
        'answer': answer,
      };
}

class LessonCard {
  const LessonCard({
    required this.id,
    required this.title,
    required this.level,
    required this.tradition,
    required this.coreTexts,
    required this.summary,
    required this.keyPoints,
    required this.discussionQuestions,
    required this.quiz,
    required this.tags,
  });

  factory LessonCard.fromJson(Map<String, dynamic> json) {
    return LessonCard(
      id: json['id'] as String,
      title: json['title'] as String,
      level: json['level'] as String,
      tradition: json['tradition'] as String,
      coreTexts: (json['core_texts'] as List<dynamic>).cast<String>(),
      summary: json['summary'] as String,
      keyPoints: (json['key_points'] as List<dynamic>).cast<String>(),
      discussionQuestions:
          (json['discussion_questions'] as List<dynamic>).cast<String>(),
      quiz: (json['quiz_mcq'] as List<dynamic>)
          .map((e) => QuizMcq.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
    );
  }

  factory LessonCard.fromJsonString(String source) {
    return LessonCard.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  final String id;
  final String title;
  final String level;
  final String tradition;
  final List<String> coreTexts;
  final String summary;
  final List<String> keyPoints;
  final List<String> discussionQuestions;
  final List<QuizMcq> quiz;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'level': level,
        'tradition': tradition,
        'core_texts': coreTexts,
        'summary': summary,
        'key_points': keyPoints,
        'discussion_questions': discussionQuestions,
        'quiz_mcq': quiz.map((e) => e.toJson()).toList(growable: false),
        'tags': tags,
      };
}
