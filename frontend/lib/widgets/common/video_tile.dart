import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class VideoTile extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const VideoTile({super.key, this.width, this.height, this.borderRadius = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.thumbnailBg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
