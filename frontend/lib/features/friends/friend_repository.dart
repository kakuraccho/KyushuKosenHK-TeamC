import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'friend_model.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.read(apiClientProvider));
});

class FriendRepository {
  const FriendRepository(this._dio);

  final Dio _dio;

  Future<Friend> sendFriendRequest(String followingId) async {
    try {
      final response = await _dio.post(
        '/api/v1/friends/requests',
        data: {'following_id': followingId},
      );
      return Friend.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('sendFriendRequest failed: $e');
      rethrow;
    }
  }

  Future<List<Friend>> fetchPendingRequests() async {
    try {
      final response = await _dio.get('/api/v1/friends/requests/pending');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchPendingRequests failed: $e');
      rethrow;
    }
  }

  Future<void> respondToRequest({
    required String id,
    required bool accept,
  }) async {
    try {
      await _dio.patch(
        '/api/v1/friends/requests/$id',
        data: {'accept': accept},
      );
    } on DioException catch (e) {
      debugPrint('respondToRequest failed: $e');
      rethrow;
    }
  }

  Future<List<Friend>> fetchFriends() async {
    try {
      final response = await _dio.get('/api/v1/friends');
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('fetchFriends failed: $e');
      rethrow;
    }
  }
}
