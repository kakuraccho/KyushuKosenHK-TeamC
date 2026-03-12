import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../features/video/video_model.dart';
import '../../features/video/video_provider.dart';
import '../../widgets/common/post_form_sheet.dart';
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
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Failed to load videos',
                style: TextStyle(color: AppColors.onSurface, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(videoListProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: Text(
                'No videos yet',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 16,
                ),
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
            itemBuilder: (context, index) =>
                _VideoGridItem(video: videos[index]),
          );
        },
      ),
    );
  }
}

class _VideoGridItem extends StatelessWidget {
  const _VideoGridItem({required this.video});
  final VideoModel video;

  void _showPostForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PostFormSheet(initialVideo: video),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPostForm(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoTile(borderRadius: 28, storageUrl: video.storageUrl),
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.upload, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
