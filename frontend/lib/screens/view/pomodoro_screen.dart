import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/video_tile.dart';

class PomodoroView extends StatefulWidget {
  const PomodoroView({super.key});

  @override
  State<PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<PomodoroView> {
  int _selected = 0;

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
              selected: _selected,
              onChanged: (index) => setState(() => _selected = index),
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
            _FocusHistoryChart(selectedIndex: _selected),
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

class _WeekMonthYearToggle extends StatelessWidget {
  const _WeekMonthYearToggle({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

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
          final isSelected = selected == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
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

class _FocusHistoryChart extends StatelessWidget {
  const _FocusHistoryChart({required this.selectedIndex});

  final int selectedIndex;

  static const _weekData = [45.0, 90.0, 60.0, 120.0, 30.0, 75.0, 50.0];
  static const _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _monthData = [300.0, 420.0, 280.0, 390.0];
  static const _monthLabels = ['Week1', 'Week2', 'Week3', 'Week4'];

  static const _yearData = [
    600.0, 500.0, 750.0, 480.0, 920.0, 840.0,
    710.0, 630.0, 880.0, 760.0, 540.0, 690.0,
  ];
  static const _yearLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<double> get _data {
    switch (selectedIndex) {
      case 1:
        return _monthData;
      case 2:
        return _yearData;
      default:
        return _weekData;
    }
  }

  List<String> get _labels {
    switch (selectedIndex) {
      case 1:
        return _monthLabels;
      case 2:
        return _yearLabels;
      default:
        return _weekLabels;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final labels = _labels;
    final maxY = data.reduce((a, b) => a > b ? a : b);
    // Round up to nearest nice interval
    final interval = _calcInterval(maxY);
    final adjustedMaxY = (maxY / interval).ceil() * interval.toDouble();

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: adjustedMaxY,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} min',
                  const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[idx],
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: interval.toDouble(),
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  );
                },
              ),
              axisNameWidget: const Text(
                'min',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              axisNameSize: 18,
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval.toDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.surfaceContainer,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i],
                  color: AppColors.secondary,
                  width: selectedIndex == 2 ? 14 : 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  int _calcInterval(double maxValue) {
    if (maxValue <= 60) return 15;
    if (maxValue <= 150) return 30;
    if (maxValue <= 500) return 100;
    return 200;
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
