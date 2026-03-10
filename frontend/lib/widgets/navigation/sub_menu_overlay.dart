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
      height: 71,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Pomodoro',
            isSelected: selectedTab == 0,
            isLeft: true,
            isRight: false,
            onTap: () => onTabSelected(0),
          ),
          _Segment(
            label: 'Videos',
            isSelected: selectedTab == 1,
            isLeft: false,
            isRight: true,
            onTap: () => onTabSelected(1),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLeft;
  final bool isRight;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isSelected,
    required this.isLeft,
    required this.isRight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 71,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.secondaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLeft ? 35 : 8),
              bottomLeft: Radius.circular(isLeft ? 35 : 8),
              topRight: Radius.circular(isRight ? 35 : 8),
              bottomRight: Radius.circular(isRight ? 35 : 8),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: isSelected ? AppColors.onSecondary : AppColors.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
