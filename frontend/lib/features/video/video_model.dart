class VideoModel {
  VideoModel({
    required this.id,
    required this.userId,
    required this.storageUrl,
    this.thumbnailUrl,
    this.duration,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String storageUrl;
  final String? thumbnailUrl;
  final int? duration;
  final DateTime createdAt;

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storageUrl: json['storage_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
