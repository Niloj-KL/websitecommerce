import '../core/http_client.dart';
import '../core/user_session.dart';
import '../models/user_profile.dart';

class AuthService {
  Future<UserProfile> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final res = await dio.post(
      '/auth/signup',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
      },
    );
    final data = res.data as Map<String, dynamic>;
    final token = (data['token'] ?? '').toString();
    if (token.isNotEmpty) {
      await UserSessionStore.saveToken(token);
    }
    return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final res = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    final token = (data['token'] ?? '').toString();
    if (token.isNotEmpty) {
      await UserSessionStore.saveToken(token);
    }
    return UserProfile.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserProfile> me() async {
    final res = await dio.get('/me');
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (_) {}
    await UserSessionStore.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await UserSessionStore.getToken();
    return token != null && token.isNotEmpty;
  }
}
