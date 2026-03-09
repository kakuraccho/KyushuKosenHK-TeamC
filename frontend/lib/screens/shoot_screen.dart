import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/common/app_bar.dart';

class ShootScreen extends StatefulWidget {
  const ShootScreen({super.key});

  @override
  State<ShootScreen> createState() => _ShootScreenState();
}

class _ShootScreenState extends State<ShootScreen> {
  bool _isRecording = false;

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
              child: Container(color: AppColors.thumbnailBg),
            ),
          ),
        ),
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => setState(() => _isRecording = !_isRecording),
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
