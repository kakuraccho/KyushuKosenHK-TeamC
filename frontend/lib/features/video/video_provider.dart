import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'video_model.dart';
import 'video_repository.dart';

final videoListProvider =
    AsyncNotifierProvider<VideoListNotifier, List<VideoModel>>(
  VideoListNotifier.new,
);

class VideoListNotifier extends AsyncNotifier<List<VideoModel>> {
  @override
  FutureOr<List<VideoModel>> build() async {
    return ref.read(videoRepositoryProvider).fetchVideos();
  }

  Future<void> uploadVideo(String filePath) async {
    final repo = ref.read(videoRepositoryProvider);
    final newVideo = await repo.uploadVideo(filePath);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([newVideo, ...current]);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(videoRepositoryProvider).fetchVideos(),
    );
  }
}
