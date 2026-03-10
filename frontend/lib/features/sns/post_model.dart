class Post {
  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.videoUrl,
    required this.comment,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String? videoUrl;
  final String comment;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      videoUrl: json['video_url'] as String?,
      comment: json['comment'] as String,
      visibility: json['visibility'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'video_url': videoUrl,
      'comment': comment,
      'visibility': visibility,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
