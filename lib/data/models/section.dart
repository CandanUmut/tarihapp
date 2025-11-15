class Section {
  const Section({
    required this.id,
    required this.lessonId,
    required this.order,
    required this.heading,
    required this.bodyMarkdown,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      order: json['order'] as int,
      heading: json['heading'] as String,
      bodyMarkdown: json['bodyMarkdown'] as String,
    );
  }

  final String id;
  final String lessonId;
  final int order;
  final String heading;
  final String bodyMarkdown;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'order': order,
        'heading': heading,
        'bodyMarkdown': bodyMarkdown,
      };
}
