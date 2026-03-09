import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                current: currentIndex,
                onTap: onTap,
                icon: Icons.schedule_outlined,
                label: 'View',
              ),
              _NavItem(
                index: 1,
                current: currentIndex,
                onTap: onTap,
                icon: Icons.radio_button_checked,
                label: 'Shoot',
              ),
              _NavItem(
                index: 2,
                current: currentIndex,
                onTap: onTap,
                icon: Icons.people_alt_outlined,
                label: 'SNS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int current;
  final ValueChanged<int> onTap;
  final IconData icon;
  final String label;

  const _NavItem({
    required this.index,
    required this.current,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 32,
              decoration: isActive
                  ? BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null,
              child: Icon(
                icon,
                size: 24,
                color: isActive ? AppColors.secondary : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: isActive ? AppColors.secondary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
