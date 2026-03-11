class Post {
  Post({
    required this.id,
    required this.userId,
    this.videoId,
    required this.content,
    required this.visibility,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? videoId;
  final String content;
  final String visibility;
  final DateTime createdAt;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      videoId: json['video_id'] as String?,
      content: json['content'] as String,
      visibility: json['visibility'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video_id': videoId,
      'content': content,
      'visibility': visibility,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
