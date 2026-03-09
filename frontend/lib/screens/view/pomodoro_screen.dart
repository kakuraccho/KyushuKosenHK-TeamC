import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/video_tile.dart';

class PomodoroView extends StatelessWidget {
  const PomodoroView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const _WeekMonthYearToggle(),
            const SizedBox(height: 20),
            const Text(
              'Focus History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            const _VideoRow(),
            const SizedBox(height: 20),
            const Text(
              'Total Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            const _VideoRow(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Connected button group: Week / Month / Year (display only)
class _WeekMonthYearToggle extends StatelessWidget {
  const _WeekMonthYearToggle();

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
          // Week – selected
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(35),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Week',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: AppColors.onSecondary,
                ),
              ),
            ),
          ),
          // Month – unselected
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Month',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ),
          ),
          // Year – unselected (right outer corners round)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Year',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoRow extends StatelessWidget {
  const _VideoRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - 8) / 3;
        return SizedBox(
          height: 218,
          child: Row(
            children: [
              VideoTile(width: tileWidth, height: 218),
              const SizedBox(width: 4),
              VideoTile(width: tileWidth, height: 218),
              const SizedBox(width: 4),
              VideoTile(width: tileWidth, height: 218),
            ],
          ),
        );
      },
    );
  }
}
