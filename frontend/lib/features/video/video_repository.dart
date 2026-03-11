import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'video_model.dart';

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(ref.read(apiClientProvider));
});

class VideoRepository {
  VideoRepository(this._dio);

  final Dio _dio;

  Future<VideoModel> uploadVideo(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '/api/v1/videos',
        data: formData,
      );

      return VideoModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Failed to upload video: $e');
      rethrow;
    }
  }

  Future<List<VideoModel>> fetchVideos() async {
    try {
      final response = await _dio.get('/api/v1/videos');

      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('Failed to fetch videos: $e');
      rethrow;
    }
  }

  Future<VideoModel> fetchVideo(String id) async {
    try {
      final response = await _dio.get('/api/v1/videos/$id');

      return VideoModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Failed to fetch video: $e');
      rethrow;
    }
  }
}
