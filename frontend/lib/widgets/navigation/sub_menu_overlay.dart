import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Pomodoro / Videos segmented button overlay.
/// Design from Figma node-id=1-16060.
class SubMenuOverlay extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const SubMenuOverlay({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  static const _outlineColor = Color(0xFF938F99);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 225,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _outlineColor),
          borderRadius: BorderRadius.circular(100),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Segment(
                label: 'Pomodoro',
                isSelected: selectedTab == 0,
                selectedIcon: Icons.check,
                unselectedIcon: Icons.timer,
                onTap: () => onTabSelected(0),
              ),
              // divider between segments
              Container(width: 1, color: _outlineColor),
              _Segment(
                label: 'Videos',
                isSelected: selectedTab == 1,
                selectedIcon: Icons.check,
                unselectedIcon: Icons.videocam_outlined,
                onTap: () => onTabSelected(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData selectedIcon;
  final IconData? unselectedIcon;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.isSelected,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // secondary bg (light) → onSecondary (dark text); secondaryContainer bg (dark) → onSecondaryContainer (light text)
    final color =
        isSelected ? AppColors.onSecondary : AppColors.onSecondaryContainer;
    final icon = isSelected ? selectedIcon : unselectedIcon;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(
          // Selected: bright accent (secondary), unselected: muted dark (secondaryContainer)
          color: isSelected ? AppColors.secondary : AppColors.secondaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
