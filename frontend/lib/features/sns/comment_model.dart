class Comment {
  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
