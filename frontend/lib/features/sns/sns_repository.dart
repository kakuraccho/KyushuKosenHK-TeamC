import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'post_model.dart';

final snsRepositoryProvider = Provider<SnsRepository>((ref) {
  return SnsRepository(ref.watch(apiClientProvider));
});

class SnsRepository {
  SnsRepository(this._dio);

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _dio.get('/api/v1/posts');
      final data = response.data as Map<String, dynamic>;
      final postsJson = data['posts'] as List<dynamic>;
      return postsJson
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchPosts failed: ${e.message}');
      rethrow;
    }
  }

  Future<Post> createPost({
    required String comment,
    required String visibility,
    String? videoUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/posts',
        data: {
          'comment': comment,
          'visibility': visibility,
          'video_url': videoUrl,
        },
      );
      return Post.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('createPost failed: ${e.message}');
      rethrow;
    }
  }
}
