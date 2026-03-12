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

class _WeekMonthYearToggle extends StatefulWidget {
  const _WeekMonthYearToggle();

  @override
  State<_WeekMonthYearToggle> createState() => _WeekMonthYearToggleState();
}

class _WeekMonthYearToggleState extends State<_WeekMonthYearToggle> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    const labels = ['Week', 'Month', 'Year'];
    return Container(
      height: 71,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = _selected == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selected = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(isSelected ? 35 : 20),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: isSelected
                        ? AppColors.onSecondary
                        : AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          );
        }),
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
