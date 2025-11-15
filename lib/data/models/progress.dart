class Progress {
  const Progress({
    required this.id,
    required this.contentId,
    required this.completed,
    required this.percent,
    required this.updatedAt,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      completed: json['completed'] as bool,
      percent: (json['percent'] as num).toDouble(),
      updatedAt: json['updatedAt'] as int,
    );
  }

  final String id;
  final String contentId;
  final bool completed;
  final double percent;
  final int updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'contentId': contentId,
        'completed': completed,
        'percent': percent,
        'updatedAt': updatedAt,
      };
}
