import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(apiClientProvider));
});

class SettingsRepository {
  SettingsRepository(this._dio);
  final Dio _dio;

  Future<SettingsModel> getSettings() async {
    try {
      final response = await _dio.get('/api/v1/users/me/settings');
      final data = response.data as Map<String, dynamic>;
      return SettingsModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('getSettings failed: ${e.message}');
      rethrow;
    }
  }

  Future<SettingsModel> updateSettings(SettingsModel settings) async {
    try {
      final response = await _dio.put(
        '/api/v1/users/me/settings',
        data: settings.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      return SettingsModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('updateSettings failed: ${e.message}');
      rethrow;
    }
  }
}
