class Bookmark {
  const Bookmark({
    required this.id,
    required this.contentId,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      contentId: json['contentId'] as String,
      createdAt: json['createdAt'] as int,
    );
  }

  final String id;
  final String contentId;
  final int createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'contentId': contentId,
        'createdAt': createdAt,
      };
}
