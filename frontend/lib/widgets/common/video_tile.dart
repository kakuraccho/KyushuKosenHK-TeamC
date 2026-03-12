import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../constants/app_colors.dart';

class VideoTile extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final String? storageUrl;

  const VideoTile({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 28,
    this.storageUrl,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.storageUrl != null) {
      _initController(widget.storageUrl!);
    }
  }

  Future<void> _initController(String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    await controller.initialize();
    if (!mounted) return;
    await controller.setLooping(true);
    await controller.setVolume(0);
    await controller.play();
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _initialized && _controller != null
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
      ),
    );
  }
}
