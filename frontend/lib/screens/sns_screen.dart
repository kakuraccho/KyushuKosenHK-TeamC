import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../constants/app_colors.dart';
import '../features/sns/post_model.dart';
import '../features/sns/sns_providers.dart';
import '../features/video/video_repository.dart';
import '../widgets/common/app_bar.dart';

class SnsScreen extends ConsumerStatefulWidget {
  const SnsScreen({super.key});

  @override
  ConsumerState<SnsScreen> createState() => _SnsScreenState();
}

class _SnsScreenState extends ConsumerState<SnsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

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
          child: AnimatedSwitcher(
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
                    return PageView.builder(
                      key: const ValueKey('data'),
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return _PostCard(
                          post: posts[index],
                          isActive: index == _currentPage,
                        );
                      },
                    );
                  },
                ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────
// PostCard with video playback
// ─────────────────────────────────────────

class _PostCard extends ConsumerStatefulWidget {
  const _PostCard({required this.post, required this.isActive});

  final Post post;
  final bool isActive;

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final video = await ref
          .read(videoRepositoryProvider)
          .fetchVideo(widget.post.videoId);

      final controller =
          VideoPlayerController.networkUrl(Uri.parse(video.storageUrl));
      _controller = controller;
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(true);
      if (widget.isActive) {
        await controller.play();
      }
      setState(() => _initialized = true);
    } catch (e) {
      debugPrint('_initVideo failed: $e');
    }
  }

  @override
  void didUpdateWidget(_PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final c = _controller;
    if (c == null) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _initialized && _controller != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                : Container(color: AppColors.thumbnailBg),
            if (_initialized &&
                _controller != null &&
                !_controller!.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ReelsOverlay(post: widget.post),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Overlay UI
// ─────────────────────────────────────────

class _ReelsOverlay extends StatelessWidget {
  const _ReelsOverlay({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _ReelsLeftBar(post: post)),
          const SizedBox(width: 14),
          const _ReelsRightBar(),
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
                post.userName ?? 'testuser',
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
        if (post.content != null && post.content!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            post.content!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              letterSpacing: -0.14,
            ),
          ),
        ],
        const SizedBox(height: 14),
      ],
    );
  }
}

class _ReelsRightBar extends StatelessWidget {
  const _ReelsRightBar();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.favorite_border, size: 23, color: Colors.white),
        SizedBox(height: 23),
        Icon(Icons.chat_bubble_outline, size: 23, color: Colors.white),
        SizedBox(height: 23),
        Icon(Icons.more_horiz, size: 15, color: Colors.white),
      ],
    );
  }
}

