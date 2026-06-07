import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../../core/services/api_client.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Notifier
// ─────────────────────────────────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkExistingSession();
    return const AuthInitial();
  }

  Dio get _dio => ref.read(dioProvider);
  TokenRepository get _tokens => ref.read(tokenRepositoryProvider);

  Future<void> _checkExistingSession() async {
    final hasToken = await _tokens.hasValidToken();
    if (hasToken) {
      try {
        final response = await _dio.get('/auth/me/');
        final user = User.fromJson(response.data as Map<String, dynamic>);
        state = AuthAuthenticated(user);
      } catch (_) {
        state = const AuthUnauthenticated();
      }
    } else {
      state = const AuthUnauthenticated();
    }
  }

  /// Request OTP SMS
  /*Future<void> requestOtp(String phone) async {
    state = const AuthLoading();
    try {
      await _dio.post('/auth/otp/send/', data: {'phone': phone});
      state = const AuthUnauthenticated();
    } on DioException catch (e) {
      state = AuthError(handleDioError(e).message);
    }
  }
  

  /// Verify OTP and log in
  Future<bool> verifyOtp(String phone, String otp) async {
    state = const AuthLoading();
    try {
      final response = await _dio.post('/auth/otp/verify/', data: {
        'phone': phone,
        'otp': otp,
      });
      final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
      await _tokens.saveTokens(access: tokens.access, refresh: tokens.refresh);
      state = AuthAuthenticated(tokens.user);
      return true;
    } on DioException catch (e) {
      state = AuthError(handleDioError(e).message);
      return false;
    }
  }*/
  Future<void> requestOtp(String phone) async {
    state = const AuthLoading();
    await Future.delayed(const Duration(seconds: 1));
    state = const AuthUnauthenticated();
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    state = const AuthLoading();

    await Future.delayed(const Duration(seconds: 1));

    final user = User(
      id: '1',
      email: '',
      phone: phone,
      role: UserRole.client,
      name: '',
    );

    state = AuthAuthenticated(user);
    return true;
  }

  /// Email + password login (secondary)
  /*Future<bool> loginWithEmail(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _dio.post('/auth/token/', data: {
        'email': email,
        'password': password,
      });
      final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
      await _tokens.saveTokens(access: tokens.access, refresh: tokens.refresh);
      state = AuthAuthenticated(tokens.user);
      return true;
    } on DioException catch (e) {
      state = AuthError(handleDioError(e).message);
      return false;
    }
  }*/
  Future<bool> loginWithEmail(String email, String password) async {
    state = const AuthLoading();

    await Future.delayed(const Duration(seconds: 1));

    // MOCK USER
    final user = User(
      id: '1',
      email: email,
      phone: '',
      role: UserRole.client,
      name: '',
    );

    state = AuthAuthenticated(user);
    return true;
  }

  /// Update user role after role selection
  Future<void> selectRole(UserRole role) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    state = const AuthLoading();
    try {
      final response = await _dio.patch('/auth/me/', data: {
        'role': role.name,
      });
      final updated = User.fromJson(response.data as Map<String, dynamic>);
      state = AuthAuthenticated(updated);
    } on DioException catch (e) {
      // Non-blocking — revert to previous user with role applied locally
      state = AuthAuthenticated(current.user.copyWith(role: role));
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _dio.post('/auth/logout/');
    } catch (_) {}
    await _tokens.clearTokens();
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Convenience providers
// ─────────────────────────────────────────────────────────────────────────────
final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authProvider);
  return auth is AuthAuthenticated ? auth.user : null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});

final isProviderRoleProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == UserRole.provider;
});
