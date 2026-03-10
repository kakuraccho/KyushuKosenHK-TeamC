import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class FocusAppBar extends StatelessWidget {
  final String title;

  const FocusAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.bg,
        padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
        child: Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Leading: hamburger menu
              Positioned(
                left: 4,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.onSurface, size: 24),
                  onPressed: () {},
                ),
              ),
              // Title: centered
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.onSurface,
                ),
              ),
              // Trailing: account icon
              Positioned(
                right: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: AppColors.onSurface,
                    size: 24,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
