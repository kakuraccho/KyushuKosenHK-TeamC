import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../features/sns/post_model.dart';
import '../features/sns/sns_providers.dart';
import '../widgets/common/app_bar.dart';

class SnsScreen extends ConsumerStatefulWidget {
  const SnsScreen({super.key});

  @override
  ConsumerState<SnsScreen> createState() => _SnsScreenState();
}

class _SnsScreenState extends ConsumerState<SnsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(feedProvider);

    return Column(
      children: [
        const FocusAppBar(title: 'SNS'),
        Expanded(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: feedAsync.when(
                  loading: () => const Center(
                    key: ValueKey('loading'),
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                  error: (error, _) => Center(
                    key: const ValueKey('error'),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Failed to load feed',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                ref.read(feedProvider.notifier).refresh(),
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
                  ),
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const Center(
                        key: ValueKey('empty'),
                        child: Text(
                          'No posts yet',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      key: const ValueKey('data'),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return _PostCard(post: posts[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: AppColors.onSurface,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.surfaceContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => const _PostFormBottomSheet(),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final Post post;

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.thumbnailBg),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ReelsOverlay(post: post, formatCount: _formatCount),
          ),
        ],
      ),
    );
  }
}

class _ReelsOverlay extends StatelessWidget {
  const _ReelsOverlay({required this.post, required this.formatCount});

  final Post post;
  final String Function(int) formatCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _ReelsLeftBar(post: post)),
          const SizedBox(width: 14),
          _ReelsRightBar(post: post, formatCount: formatCount),
        ],
      ),
    );
  }
}

class _ReelsLeftBar extends StatelessWidget {
  const _ReelsLeftBar({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer,
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                post.userName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                post.visibility,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          post.comment,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            letterSpacing: -0.14,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _ReelsRightBar extends StatelessWidget {
  const _ReelsRightBar({required this.post, required this.formatCount});

  final Post post;
  final String Function(int) formatCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ReelAction(
          icon: Icons.favorite_border,
          count: formatCount(post.likeCount),
        ),
        const SizedBox(height: 23),
        _ReelAction(
          icon: Icons.chat_bubble_outline,
          count: formatCount(post.commentCount),
        ),
        const SizedBox(height: 23),
        const Icon(Icons.more_horiz, size: 15, color: Colors.white),
      ],
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String count;

  const _ReelAction({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 23, color: Colors.white),
        const SizedBox(height: 12),
        Text(
          count,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }
}

class _PostFormBottomSheet extends ConsumerStatefulWidget {
  const _PostFormBottomSheet();

  @override
  ConsumerState<_PostFormBottomSheet> createState() =>
      _PostFormBottomSheetState();
}

class _PostFormBottomSheetState extends ConsumerState<_PostFormBottomSheet> {
  final _commentController = TextEditingController();
  String _visibility = 'public';
  bool _videoSelected = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(feedProvider.notifier).createPost(
            comment: comment,
            visibility: _visibility,
            videoUrl: _videoSelected ? 'mock_video.mp4' : null,
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
            controller: _commentController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Write a comment...',
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
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _visibility,
                dropdownColor: AppColors.surfaceContainer,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                ),
                underline: Container(
                  height: 1,
                  color: AppColors.secondaryContainer,
                ),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'friends', child: Text('Friends')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _visibility = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              setState(() => _videoSelected = !_videoSelected);
            },
            icon: Icon(
              _videoSelected ? Icons.check_circle : Icons.video_library,
              color: _videoSelected
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
            ),
            label: Text(
              _videoSelected ? 'mock_video.mp4' : 'Select video',
              style: TextStyle(
                color: _videoSelected
                    ? AppColors.secondary
                    : AppColors.onSurfaceVariant,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _videoSelected
                    ? AppColors.secondary
                    : AppColors.secondaryContainer,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSurface,
              disabledBackgroundColor:
                  AppColors.secondaryContainer.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onSurface,
                    ),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
