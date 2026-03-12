import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_model.dart';
import 'settings_repository.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsModel>(
        SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  @override
  FutureOr<SettingsModel> build() async {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final updated =
        await ref.read(settingsRepositoryProvider).updateSettings(settings);
    state = AsyncValue.data(updated);
  }
}
