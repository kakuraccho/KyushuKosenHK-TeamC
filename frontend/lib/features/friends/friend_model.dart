class Friend {
  const Friend({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String followerId;
  final String followingId;
  final String status;
  final DateTime createdAt;

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
