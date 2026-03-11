import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'comment_model.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.read(apiClientProvider));
});

class CommentRepository {
  CommentRepository(this._dio);

  final Dio _dio;

  Future<Comment> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/posts/$postId/comments',
        data: {'content': content},
      );
      return Comment.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('createComment failed: ${e.message}');
      rethrow;
    }
  }

  Future<List<Comment>> fetchComments(String postId) async {
    try {
      final response = await _dio.get('/api/v1/posts/$postId/comments');
      final data = response.data as Map<String, dynamic>;
      final commentsJson = data['data'] as List<dynamic>;
      return commentsJson
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchComments failed: ${e.message}');
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _dio.delete('/api/v1/posts/$postId/comments/$commentId');
    } on DioException catch (e) {
      debugPrint('deleteComment failed: ${e.message}');
      rethrow;
    }
  }
}
