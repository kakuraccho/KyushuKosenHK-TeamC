import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../debug/captured_image_viewer.dart';
import '../core/camera/camera_cache.dart';
import '../widgets/common/app_bar.dart';
import '../features/shoot/pomodoro_provider.dart';
import '../features/video/video_generator.dart';
import '../features/video/video_provider.dart';

class ShootScreen extends ConsumerStatefulWidget {
  const ShootScreen({super.key, required this.isActive});

  final bool isActive;

  @override
  ConsumerState<ShootScreen> createState() => _ShootScreenState();
}

class _ShootScreenState extends ConsumerState<ShootScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isGeneratingVideo = false;
  Timer? _captureTimer;
  final List<String> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void didUpdateWidget(ShootScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      if (_isPaused) {
        _cameraController?.resumePreview();
        _isPaused = false;
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _captureTimer?.cancel();
      _captureTimer = null;
      if (mounted) setState(() => _isRecording = false);
      ref.read(pomodoroProvider.notifier).stop();
      _cameraController?.pausePreview();
      _isPaused = true;
    }
  }

  Future<void> _initCamera() async {
    final cameras =
        cachedCameras.isNotEmpty ? cachedCameras : await availableCameras();
    if (cameras.isEmpty) return;

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopCapture();
    } else {
      _startCapture();
    }
  }

  void _startCapture() {
    setState(() {
      _isRecording = true;
      _capturedImages.clear();
    });
    ref.read(pomodoroProvider.notifier).start();
    _captureTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final controller = _cameraController;
      if (controller == null || !controller.value.isInitialized) return;
      try {
        final file = await controller.takePicture();
        debugPrint('Captured: ${file.path}');
        if (mounted) {
          setState(() => _capturedImages.add(file.path));
        }
      } catch (e) {
        debugPrint('Capture error: $e');
      }
    });
  }

  Future<void> _stopCapture() async {
    _captureTimer?.cancel();
    _captureTimer = null;
    ref.read(pomodoroProvider.notifier).stop();

    if (_capturedImages.isEmpty) {
      if (mounted) setState(() => _isRecording = false);
      return;
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
        _isGeneratingVideo = true;
      });
    }

    try {
      final videoPath = await VideoGenerator.generateFromImages(
        List.unmodifiable(_capturedImages),
      );
      if (videoPath == null) throw Exception('動画生成に失敗しました');

      final video =
          await ref.read(videoListProvider.notifier).uploadVideo(videoPath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              video != null ? '動画を保存しました' : '動画のアップロードに失敗しました'),
        ),
      );
    } catch (e) {
      debugPrint('Video generation/upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('動画の生成・アップロードに失敗しました')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingVideo = false);
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FocusAppBar(title: 'Shoot'),
        const SizedBox(height: 5),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _isInitialized
                      ? CameraPreview(_cameraController!)
                      : const ColoredBox(color: AppColors.thumbnailBg),
                  const Positioned(
                    right: 12,
                    bottom: 12,
                    child: _PomodoroTimer(),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_capturedImages.isNotEmpty)
          DebugCapturedImageStrip(
            imagePaths: List.unmodifiable(_capturedImages),
          ),
        _RecordButtonBar(
          isRecording: _isRecording,
          isLoading: _isGeneratingVideo,
          onTap: (_isRecording || !_isGeneratingVideo)
              ? _toggleRecording
              : null,
        ),
      ],
    );
  }
}

class _PomodoroTimer extends ConsumerWidget {
  const _PomodoroTimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = ref.watch(pomodoroProvider);
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$mm:$ss',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _RecordButtonBar extends StatelessWidget {
  const _RecordButtonBar({
    required this.isRecording,
    this.isLoading = false,
    required this.onTap,
  });

  final bool isRecording;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.onSecondaryContainer,
                        ),
                      )
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isRecording ? 32 : 40,
                        height: isRecording ? 32 : 40,
                        decoration: BoxDecoration(
                          color: AppColors.onSecondaryContainer,
                          borderRadius: isRecording
                              ? BorderRadius.circular(6)
                              : BorderRadius.circular(20),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
