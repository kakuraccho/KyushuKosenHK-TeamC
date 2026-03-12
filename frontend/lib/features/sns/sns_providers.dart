import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_model.dart';
import 'sns_repository.dart';

final feedProvider =
    AsyncNotifierProvider<FeedNotifier, List<Post>>(FeedNotifier.new);

class FeedNotifier extends AsyncNotifier<List<Post>> {
  @override
  FutureOr<List<Post>> build() async {
    return _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    final repository = ref.read(snsRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPosts());
  }

  Future<void> createPost({
    required String videoId,
    String? content,
    required String visibility,
  }) async {
    final repository = ref.read(snsRepositoryProvider);
    try {
      final newPost = await repository.createPost(
        videoId: videoId,
        content: content,
        visibility: visibility,
      );
      final currentPosts = state.valueOrNull ?? [];
      state = AsyncValue.data([newPost, ...currentPosts]);
    } catch (e) {
      debugPrint('createPost in notifier failed: $e');
      rethrow;
    }
  }
}
