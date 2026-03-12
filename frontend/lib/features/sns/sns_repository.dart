import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'post_model.dart';

final snsRepositoryProvider = Provider<SnsRepository>((ref) {
  return SnsRepository(ref.read(apiClientProvider));
});

class SnsRepository {
  SnsRepository(this._dio);

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _dio.get('/api/v1/posts');
      final data = response.data as Map<String, dynamic>;
      final postsJson = (data['data'] as List<dynamic>?) ?? [];
      return postsJson
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchPosts failed: ${e.message}');
      rethrow;
    }
  }

  Future<Post> createPost({
    required String videoId,
    String? content,
    required String visibility,
  }) async {
    try {
      final body = <String, dynamic>{
        'video_id': videoId,
        'visibility': visibility,
      };
      if (content != null && content.isNotEmpty) body['content'] = content;

      final response = await _dio.post('/api/v1/posts', data: body);
      final data = response.data as Map<String, dynamic>;
      return Post.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('createPost failed: ${e.message}');
      rethrow;
    }
  }
}
