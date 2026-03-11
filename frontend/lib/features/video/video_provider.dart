import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_model.dart';
import 'video_repository.dart';

final videoListProvider =
    AsyncNotifierProvider<VideoListNotifier, List<VideoModel>>(
  VideoListNotifier.new,
);

class VideoListNotifier extends AsyncNotifier<List<VideoModel>> {
  @override
  FutureOr<List<VideoModel>> build() => _fetch();

  Future<List<VideoModel>> _fetch() =>
      ref.read(videoRepositoryProvider).fetchVideos();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<VideoModel?> uploadVideo(String filePath) async {
    try {
      final video =
          await ref.read(videoRepositoryProvider).uploadVideo(filePath);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([video, ...current]);
      return video;
    } catch (e) {
      debugPrint('uploadVideo failed: $e');
      return null;
    }
  }
}
