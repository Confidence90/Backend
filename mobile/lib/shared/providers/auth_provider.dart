import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../../core/services/api_client.dart';

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
        await _tokens.clearTokens();
        state = const AuthUnauthenticated();
      }
    } else {
      state = const AuthUnauthenticated();
    }
  }

  /// Méthode générique demandée par l'UI (Login par défaut)
  Future<bool> requestOtp(String phone) async {
    return requestLoginOtp(phone);
  }

  /// Étape 1 : Demande OTP pour Connexion
  Future<bool> requestLoginOtp(String phone) async {
    state = const AuthLoading();
    try {
      await _dio.post('/auth/login/', data: {'phone_number': phone});
      state = const AuthUnauthenticated();
      return true;
    } on DioException catch (e) {
      state = AuthError(handleDioError(e).message);
      return false;
    }
  }

  /// Étape 1 : Demande OTP pour Inscription
  Future<bool> requestRegisterOtp({
    required String phone,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    state = const AuthLoading();
    try {
      await _dio.post('/auth/register/', data: {
        'phone_number': phone,
        'first_name': firstName,
        'last_name': lastName,
        'role': role.name.toUpperCase(),
      });
      state = const AuthUnauthenticated();
      return true;
    } on DioException catch (e) {
      state = AuthError(handleDioError(e).message);
      return false;
    }
  }

  /// Étape 2 : Vérification du code OTP (Gère login et register via Django)
  Future<bool> verifyOtp(String phone, String code, {bool isRegister = false}) async {
    state = const AuthLoading();
    try {
      // On essaie d'abord le login, si ça échoue avec 404, c'est peut-être une vérification d'inscription
      // Mais pour être précis, on utilise le flag isRegister
      final endpoint = isRegister ? '/auth/register/verify/' : '/auth/login/verify/';
      
      final response = await _dio.post(endpoint, data: {
        'phone_number': phone,
        'code': code,
      });
      
      final tokens = AuthTokens.fromJson(response.data as Map<String, dynamic>);
      await _tokens.saveTokens(access: tokens.access, refresh: tokens.refresh);
      
      state = AuthAuthenticated(tokens.user);
      return true;
    } on DioException catch (e) {
      state = AuthError(handleDioError(e).message);
      return false;
    }
  }

  /// Restauration de la méthode demandée par RoleSelectScreen
  Future<void> selectRole(UserRole role) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    state = const AuthLoading();
    try {
      final response = await _dio.patch('/auth/me/', data: {
        'role': role.name.toUpperCase(),
      });
      final updated = User.fromJson(response.data as Map<String, dynamic>);
      state = AuthAuthenticated(updated);
    } on DioException catch (e) {
      // Fallback local en cas d'erreur API
      state = AuthAuthenticated(current.user.copyWith(role: role));
    }
  }

  /// Restauration login email (si utilisé en fallback)
  Future<bool> loginWithEmail(String email, String password) async {
    state = const AuthLoading();
    try {
      // Note: Votre backend Django n'a pas encore cet endpoint selon l'URLconf fournie,
      // mais on le garde pour la compatibilité UI.
      state = AuthError("Le login par email n'est pas activé sur le serveur.");
      return false;
    } catch (e) {
      state = const AuthError("Erreur de connexion.");
      return false;
    }
  }

  Future<void> logout() async {
    final currentToken = await _tokens.getRefreshToken();
    state = const AuthLoading();
    try {
      if (currentToken != null) {
        await _dio.post('/auth/logout/', data: {'refresh': currentToken});
      }
    } catch (_) {}
    await _tokens.clearTokens();
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Convenience providers
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
