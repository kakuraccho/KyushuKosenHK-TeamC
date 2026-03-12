import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'friend_model.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.read(apiClientProvider));
});

class FriendRepository {
  FriendRepository(this._dio);
  final Dio _dio;

  Future<FriendRequest> sendRequest(String followingId) async {
    try {
      final response = await _dio.post(
        '/api/v1/friends/requests',
        data: {'following_id': followingId},
      );
      final data = response.data as Map<String, dynamic>;
      return FriendRequest.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('sendRequest failed: ${e.message}');
      rethrow;
    }
  }

  Future<List<FriendRequest>> fetchPendingRequests() async {
    try {
      final response = await _dio.get('/api/v1/friends/requests/pending');
      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchPendingRequests failed: ${e.message}');
      rethrow;
    }
  }

  Future<void> respondToRequest(String id, {required bool accept}) async {
    try {
      await _dio.patch(
        '/api/v1/friends/requests/$id',
        data: {'accept': accept},
      );
    } on DioException catch (e) {
      debugPrint('respondToRequest failed: ${e.message}');
      rethrow;
    }
  }

  Future<List<FriendRequest>> fetchFriends() async {
    try {
      final response = await _dio.get('/api/v1/friends');
      final data = response.data as Map<String, dynamic>;
      final list = (data['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchFriends failed: ${e.message}');
      rethrow;
    }
  }
}
