import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/video_tile.dart';

enum ViewPeriod { week, month, year }

class PomodoroView extends StatefulWidget {
  const PomodoroView({super.key});

  @override
  State<PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<PomodoroView> {
  ViewPeriod _selectedPeriod = ViewPeriod.week;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _WeekMonthYearToggle(
              selectedPeriod: _selectedPeriod,
              onChanged: (period) => setState(() => _selectedPeriod = period),
            ),
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
            _buildPeriodContent(_selectedPeriod),
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
            _buildPeriodContent(_selectedPeriod),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // TODO: Replace with actual content per period
  Widget _buildPeriodContent(ViewPeriod period) {
    return const _VideoRow();
  }
}

class _WeekMonthYearToggle extends StatelessWidget {
  final ViewPeriod selectedPeriod;
  final ValueChanged<ViewPeriod> onChanged;

  const _WeekMonthYearToggle({
    required this.selectedPeriod,
    required this.onChanged,
  });

  // Outer corners (pill edge) = 35 (half of 71px height), inner corners = 8
  BorderRadius _segmentRadius(ViewPeriod segmentPeriod) {
    const double outer = 35;
    const double inner = 8;

    if (segmentPeriod == selectedPeriod) {
      return BorderRadius.circular(outer);
    }
    if (segmentPeriod == ViewPeriod.week) {
      return const BorderRadius.only(
        topLeft: Radius.circular(outer),
        bottomLeft: Radius.circular(outer),
        topRight: Radius.circular(inner),
        bottomRight: Radius.circular(inner),
      );
    }
    if (segmentPeriod == ViewPeriod.year) {
      return const BorderRadius.only(
        topLeft: Radius.circular(inner),
        bottomLeft: Radius.circular(inner),
        topRight: Radius.circular(outer),
        bottomRight: Radius.circular(outer),
      );
    }
    return BorderRadius.circular(inner);
  }

  Widget _buildSegment(ViewPeriod period, String label) {
    final isSelected = period == selectedPeriod;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.secondaryContainer,
            borderRadius: _segmentRadius(period),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 71,
      child: Row(
        children: [
          _buildSegment(ViewPeriod.week, 'Week'),
          const SizedBox(width: 2),
          _buildSegment(ViewPeriod.month, 'Month'),
          const SizedBox(width: 2),
          _buildSegment(ViewPeriod.year, 'Year'),
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
