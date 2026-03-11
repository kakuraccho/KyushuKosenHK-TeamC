import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/supabase/supabase_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Supabase Auth でユーザー作成
    final response =
        await supabase.auth.signUp(email: email, password: password);

    // UID を取得
    final uid = response.user?.id;

    // BFF にユーザー情報を登録
    await _dio.post('/api/v1/auth/signup', data: {
      'id': uid,
      'name': name,
      'email': email,
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
