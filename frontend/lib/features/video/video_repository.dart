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

  Future<List<VideoModel>> fetchVideos() async {
    try {
      final response = await _dio.get('/api/v1/videos');
      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>?) ?? [];
      return list
          .map((json) => VideoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchVideos failed: ${e.message}');
      rethrow;
    }
  }

  Future<VideoModel> fetchVideo(String id) async {
    try {
      final response = await _dio.get('/api/v1/videos/$id');
      final data = response.data as Map<String, dynamic>;
      return VideoModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('fetchVideo failed: ${e.message}');
      rethrow;
    }
  }

  Future<VideoModel> uploadVideo(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(filePath, filename: 'video.mp4'),
      });
      final response = await _dio.post(
        '/api/v1/videos',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      final data = response.data as Map<String, dynamic>;
      return VideoModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('uploadVideo failed: ${e.message}');
      rethrow;
    }
  }
}
