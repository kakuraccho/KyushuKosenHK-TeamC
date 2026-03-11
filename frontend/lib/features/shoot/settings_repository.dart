import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dio = ref.read(apiClientProvider);
  return SettingsRepository(dio);
});

class SettingsRepository {
  final Dio _dio;
  SettingsRepository(this._dio);

  Future<SettingsModel> getSettings() async {
    try {
      final response = await _dio.get('/api/v1/users/me/settings');
      return SettingsModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Failed to get settings: $e');
      rethrow;
    }
  }

  Future<SettingsModel> updateSettings(SettingsModel settings) async {
    try {
      final response = await _dio.put(
        '/api/v1/users/me/settings',
        data: {
          'time_pomodoro': settings.timePomodoro,
          'time_short_break': settings.timeShortBreak,
          'time_long_break': settings.timeLongBreak,
          'is_auto_start_session': settings.isAutoStartSession,
          'long_break_interval': settings.longBreakInterval,
        },
      );
      return SettingsModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Failed to update settings: $e');
      rethrow;
    }
  }
}
