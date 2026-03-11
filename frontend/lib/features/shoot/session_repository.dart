import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final dio = ref.read(apiClientProvider);
  return SessionRepository(dio);
});

class SessionRepository {
  final Dio _dio;
  SessionRepository(this._dio);

  Future<void> postSession({
    required int duration,
    required bool isCompleted,
  }) async {
    try {
      await _dio.post('/api/v1/sessions', data: {
        'duration': duration,
        'is_completed': isCompleted,
      });
    } catch (e) {
      debugPrint('Failed to post session: $e');
    }
  }
}
