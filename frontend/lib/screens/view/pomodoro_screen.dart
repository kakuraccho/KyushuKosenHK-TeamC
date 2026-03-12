import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';

class PomodoroView extends StatefulWidget {
  const PomodoroView({super.key});

  @override
  State<PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<PomodoroView> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          _WeekMonthYearToggle(
            selected: _selected,
            onChanged: (i) => setState(() => _selected = i),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Focus History',
                    textAlign: TextAlign.center,
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActivityReport(selectedIndex: _selected),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// Toggle
// ──────────────────────────────────────────

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

// ──────────────────────────────────────────
// Chart
// ──────────────────────────────────────────

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
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            getDrawingHorizontalLine: (_) => const FlLine(
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

// ──────────────────────────────────────────
// Activity Report
// ──────────────────────────────────────────

class _ActivityReport extends StatelessWidget {
  const _ActivityReport({required this.selectedIndex});
  final int selectedIndex;

  static const _totalMinutes = [470, 1890, 22680];
  static const _sessionCount = [12, 48, 576];
  static const _completionRate = [83, 79, 81];
  static const _longestMinutes = [75, 120, 150];

  String _formatTime(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalMinutes[selectedIndex];
    final sessions = _sessionCount[selectedIndex];
    final rate = _completionRate[selectedIndex];
    final longest = _longestMinutes[selectedIndex];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.timer_outlined,
                label: '総勉強時間',
                value: _formatTime(total),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.repeat_rounded,
                label: 'セッション数',
                value: '$sessionsセッション',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline,
                label: '完了率',
                value: '$rate%',
                valueColor: rate >= 80
                    ? AppColors.secondary
                    : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_outlined,
                label: '最長集中',
                value: _formatTime(longest),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
