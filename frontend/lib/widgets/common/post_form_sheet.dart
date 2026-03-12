import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../features/sns/sns_providers.dart';
import '../../features/video/video_model.dart';
import '../../features/video/video_provider.dart';

class PostFormSheet extends ConsumerStatefulWidget {
  /// 事前に選択済みの動画。null の場合はドロップダウンで選ばせる。
  final VideoModel? initialVideo;

  const PostFormSheet({super.key, this.initialVideo});

  @override
  ConsumerState<PostFormSheet> createState() => _PostFormSheetState();
}

class _PostFormSheetState extends ConsumerState<PostFormSheet> {
  final _contentController = TextEditingController();
  String _visibility = 'public';
  late VideoModel? _selectedVideo;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedVideo = widget.initialVideo;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final video = _selectedVideo;
    if (video == null) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(feedProvider.notifier).createPost(
            videoId: video.id,
            content: _contentController.text.trim().isEmpty
                ? null
                : _contentController.text.trim(),
            visibility: _visibility,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final videosAsync = ref.watch(videoListProvider);
    final locked = widget.initialVideo != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'New Post',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              hintStyle: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Visibility: ',
                style: TextStyle(color: AppColors.onSurface, fontSize: 14),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _visibility,
                dropdownColor: AppColors.surfaceContainer,
                style: const TextStyle(
                    color: AppColors.onSurface, fontSize: 14),
                underline: Container(
                    height: 1, color: AppColors.secondaryContainer),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'friends', child: Text('Friends')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _visibility = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 動画選択エリア
          if (locked)
            // 事前選択済み：ロック表示
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.initialVideo!.id.substring(0, 8),
                      style: const TextStyle(
                          color: AppColors.secondary, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            // 動画一覧から選択
            videosAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.secondary),
              ),
              error: (_, _) => const Text(
                'Failed to load videos',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              data: (videos) {
                if (videos.isEmpty) {
                  return const Text(
                    'No videos available. Record a timelapse first.',
                    style: TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 13),
                  );
                }
                return DropdownButtonFormField<VideoModel>(
                  initialValue: _selectedVideo,
                  dropdownColor: AppColors.surfaceContainer,
                  style: const TextStyle(
                      color: AppColors.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Select a video',
                    hintStyle: TextStyle(
                      color: AppColors.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                    prefixIcon: const Icon(Icons.video_library,
                        color: AppColors.onSurfaceVariant),
                  ),
                  items: videos
                      .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(
                              v.id.substring(0, 8),
                              style: const TextStyle(
                                  color: AppColors.onSurface),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedVideo = v),
                );
              },
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                (_isSubmitting || _selectedVideo == null) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSurface,
              disabledBackgroundColor:
                  AppColors.secondaryContainer.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.onSurface),
                  )
                : const Text('Post',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
