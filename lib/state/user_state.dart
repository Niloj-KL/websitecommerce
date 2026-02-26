import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

class UserState {
  final bool loading;
  final UserProfile? profile;

  const UserState({this.loading = false, this.profile});

  bool get isLoggedIn => profile != null;

  UserState copyWith({bool? loading, UserProfile? profile, bool clearProfile = false}) {
    return UserState(
      loading: loading ?? this.loading,
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final AuthService _auth;
  UserNotifier(this._auth) : super(const UserState());

  Future<void> restoreSession() async {
    final loggedIn = await _auth.isLoggedIn();
    if (!loggedIn) {
      state = state.copyWith(clearProfile: true);
      return;
    }
    try {
      final profile = await _auth.me();
      state = state.copyWith(profile: profile, loading: false);
    } catch (_) {
      await _auth.logout();
      state = state.copyWith(clearProfile: true, loading: false);
    }
  }

  Future<String?> signup({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    state = state.copyWith(loading: true);
    try {
      final profile = await _auth.signup(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );
      state = state.copyWith(loading: false, profile: profile);
      return null;
    } catch (_) {
      state = state.copyWith(loading: false);
      return 'Could not create account. Please check your details.';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true);
    try {
      final profile = await _auth.login(email: email, password: password);
      state = state.copyWith(loading: false, profile: profile);
      return null;
    } catch (_) {
      state = state.copyWith(loading: false);
      return 'Login failed. Please check your email and password.';
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true);
    await _auth.logout();
    state = state.copyWith(loading: false, clearProfile: true);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(AuthService());
});
