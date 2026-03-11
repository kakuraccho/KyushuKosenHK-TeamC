import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../features/video/video_provider.dart';
import '../../widgets/common/video_tile.dart';

class VideosView extends ConsumerWidget {
  const VideosView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videoListProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: videosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '動画の取得に失敗しました',
                style: TextStyle(color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.read(videoListProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
              ),
            ],
          ),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: Text(
                '動画がありません\nShoot画面で撮影してください',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            );
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 121 / 214,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) => VideoTile(
              borderRadius: 28,
              storageUrl: videos[index].storageUrl,
            ),
          );
        },
      ),
    );
  }
}
