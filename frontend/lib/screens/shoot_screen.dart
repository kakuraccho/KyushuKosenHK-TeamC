import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../debug/captured_image_viewer.dart';
import '../core/camera/camera_cache.dart';
import '../widgets/common/app_bar.dart';
import '../features/shoot/pomodoro_provider.dart';

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
  Timer? _captureTimer;
  final List<String> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    // 常にバックグラウンドで初期化しておき、非アクティブ時はすぐpauseする。
    // これにより初回タブ表示時の待ち時間を最小化する。
    _initCamera();
  }

  @override
  void didUpdateWidget(ShootScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // pause済みのときだけ resumePreview を呼ぶ。
      // 初回遷移時は一度も pause していないため、呼ぶと例外が出る。
      if (_isPaused) {
        _cameraController?.resumePreview();
        _isPaused = false;
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      // タブが非アクティブになったら映像ストリームのみ停止。
      // dispose せず pausePreview するだけなので、Texture へのフレーム更新が止まり
      // 他画面のちらつきが解消される。再開も resumePreview で即座に戻る。
      _captureTimer?.cancel();
      _captureTimer = null;
      if (mounted) setState(() => _isRecording = false);
      ref.read(pomodoroProvider.notifier).stop();
      _cameraController?.pausePreview();
      _isPaused = true;
    }
  }

  Future<void> _initCamera() async {
    // アプリ起動時にキャッシュ済みのリストを使い、未取得の場合のみ再取得する
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

  void _stopCapture() {
    _captureTimer?.cancel();
    _captureTimer = null;
    setState(() => _isRecording = false);
    ref.read(pomodoroProvider.notifier).stop();
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
        // AppBar の内側 top パディング (5px) と同じ間隔
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
          onTap: _toggleRecording,
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

/// ボタン部分を別ウィジェットに分離することで、_isRecording 変化時に
/// カメラプレビュー側が rebuild されるのを防ぐ。
class _RecordButtonBar extends StatelessWidget {
  const _RecordButtonBar({
    required this.isRecording,
    required this.onTap,
  });

  final bool isRecording;
  final VoidCallback onTap;

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
                child: AnimatedContainer(
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
