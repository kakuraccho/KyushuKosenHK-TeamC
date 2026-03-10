import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../widgets/common/app_bar.dart';
import '../features/shoot/pomodoro_provider.dart';

class ShootScreen extends ConsumerStatefulWidget {
  const ShootScreen({super.key});

  @override
  ConsumerState<ShootScreen> createState() => _ShootScreenState();
}

class _ShootScreenState extends ConsumerState<ShootScreen> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isRecording = false;
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pomodoroProvider.notifier).start();
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (!mounted) return;
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
    setState(() => _isRecording = true);
    _captureTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final controller = _cameraController;
      if (controller == null || !controller.value.isInitialized) return;
      try {
        final file = await controller.takePicture();
        debugPrint('Captured: ${file.path}');
      } catch (e) {
        debugPrint('Capture error: $e');
      }
    });
  }

  void _stopCapture() {
    _captureTimer?.cancel();
    _captureTimer = null;
    setState(() => _isRecording = false);
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _isInitialized
                  ? CameraPreview(_cameraController!)
                  : Container(color: AppColors.thumbnailBg),
            ),
          ),
        ),
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: GestureDetector(
              onTap: _toggleRecording,
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
                    width: _isRecording ? 32 : 40,
                    height: _isRecording ? 32 : 40,
                    decoration: BoxDecoration(
                      color: AppColors.onSecondaryContainer,
                      borderRadius: _isRecording
                          ? BorderRadius.circular(6)
                          : BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
