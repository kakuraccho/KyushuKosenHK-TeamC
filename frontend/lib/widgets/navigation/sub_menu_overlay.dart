import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Pomodoro / Videos connected button group overlay.
/// Design from Figma node-id=1-16060.
class SubMenuOverlay extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const SubMenuOverlay({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(35),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Pomodoro',
            icon: selectedTab == 0 ? Icons.check : Icons.timer_outlined,
            isSelected: selectedTab == 0,
            onTap: () => onTabSelected(0),
          ),
          const SizedBox(width: 4),
          _Segment(
            label: 'Videos',
            icon: selectedTab == 1 ? Icons.check : Icons.image_outlined,
            isSelected: selectedTab == 1,
            onTap: () => onTabSelected(1),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.bounceInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.onSecondary : AppColors.onSecondaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: isSelected ? AppColors.onSecondary : AppColors.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
