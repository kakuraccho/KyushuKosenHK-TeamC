import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../core/camera/camera_cache.dart';
import '../debug/captured_image_viewer.dart';
import '../features/shoot/pomodoro_provider.dart';
import '../features/video/video_generator.dart';
import '../features/video/video_provider.dart';
import '../widgets/common/app_bar.dart';
import '../widgets/common/post_form_sheet.dart';

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
  bool _isGenerating = false;
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
      _generateAndUpload();
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

  Future<void> _generateAndUpload() async {
    _captureTimer?.cancel();
    _captureTimer = null;
    ref.read(pomodoroProvider.notifier).stop();
    setState(() {
      _isRecording = false;
      _isGenerating = true;
    });

    try {
      if (_capturedImages.isEmpty) {
        setState(() => _isGenerating = false);
        return;
      }

      // 1. タイムラプス生成
      final outputPath = await VideoGenerator.generateFromImages(
        List.from(_capturedImages),
      );
      if (!mounted) return;
      if (outputPath == null) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate video')),
        );
        return;
      }

      // 2. アップロード
      final uploadedVideo =
          await ref.read(videoListProvider.notifier).uploadVideo(outputPath);
      if (!mounted) return;

      setState(() {
        _isGenerating = false;
        _capturedImages.clear();
      });

      // 3. 投稿フォームを表示
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => PostFormSheet(initialVideo: uploadedVideo),
      );
    } catch (e) {
      debugPrint('_generateAndUpload error: $e');
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload video')),
        );
      }
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
          isGenerating: _isGenerating,
          onTap: _isGenerating ? null : _toggleRecording,
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
    required this.isGenerating,
    required this.onTap,
  });

  final bool isRecording;
  final bool isGenerating;
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
                child: isGenerating
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
