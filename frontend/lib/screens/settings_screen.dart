import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../features/shoot/settings_model.dart';
import '../features/shoot/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SettingsModel? _draft;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(settingsProvider).valueOrNull;
    if (current != null) _draft = current;
  }

  Future<void> _save() async {
    if (_draft == null) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(settingsProvider.notifier).saveSettings(_draft!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save settings')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.onSurface,
        title: const Text('User Settings',
            style: TextStyle(color: AppColors.onSurface)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.secondary))
                : const Text('Save',
                    style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load settings',
                  style: TextStyle(color: AppColors.onSurface)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(settingsProvider),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.onSurface),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (settings) {
          _draft ??= settings;
          final d = _draft!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _SectionLabel('Pomodoro Timer'),
              _MinutesSlider(
                label: 'Focus Time',
                value: d.timePomodoro,
                min: 1,
                max: 120,
                onChanged: (v) =>
                    setState(() => _draft = d.copyWith(timePomodoro: v)),
              ),
              _MinutesSlider(
                label: 'Short Break',
                value: d.timeShortBreak,
                min: 1,
                max: 60,
                onChanged: (v) =>
                    setState(() => _draft = d.copyWith(timeShortBreak: v)),
              ),
              _MinutesSlider(
                label: 'Long Break',
                value: d.timeLongBreak,
                min: 1,
                max: 60,
                onChanged: (v) =>
                    setState(() => _draft = d.copyWith(timeLongBreak: v)),
              ),
              const SizedBox(height: 16),
              const _SectionLabel('Session'),
              _StepperTile(
                label: 'Long Break Interval',
                subtitle: 'sessions before long break',
                value: d.longBreakInterval,
                min: 1,
                max: 100,
                onChanged: (v) =>
                    setState(() => _draft = d.copyWith(longBreakInterval: v)),
              ),
              const SizedBox(height: 8),
              _SwitchTile(
                label: 'Auto Start Session',
                value: d.isAutoStartSession,
                onChanged: (v) =>
                    setState(() => _draft = d.copyWith(isAutoStartSession: v)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MinutesSlider extends StatelessWidget {
  const _MinutesSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.onSurface, fontSize: 14)),
              Text('$value min',
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: AppColors.secondary,
            inactiveColor: AppColors.secondaryContainer,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.onSurface, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove, color: AppColors.onSurface),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text('$value',
              style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.onSurface),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.onSurface, fontSize: 14)),
          Switch(
            value: value,
            activeThumbColor: AppColors.secondary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
