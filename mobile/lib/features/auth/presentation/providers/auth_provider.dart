import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({bool? isLoading, String? error, Map<String, dynamic>? user}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        user: user ?? this.user,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final _api     = ApiService();
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(const AuthState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final token = await _storage.read(key: AppConstants.kAccessToken);
    if (token == null) return;
    try {
      final user = await _api.getMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<bool> requestLoginOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.requestOtp(phone);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> verifyLogin(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.verifyOtp(phone, code, purpose: 'login');
      await _saveTokens(data);
      state = state.copyWith(isLoading: false, user: data['user']);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> requestRegisterOtp({
    required String phone,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.registerRequest({
        'phone_number': phone,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> verifyRegister(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.registerVerify(phone, code);
      await _saveTokens(data);
      state = state.copyWith(isLoading: false, user: data['user']);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final access  = data['access']  as String?;
    final refresh = data['refresh'] as String?;
    final user    = data['user']    as Map<String, dynamic>?;
    if (access  != null) await _storage.write(key: AppConstants.kAccessToken,  value: access);
    if (refresh != null) await _storage.write(key: AppConstants.kRefreshToken, value: refresh);
    if (user    != null) {
      await _storage.write(key: AppConstants.kUserId,    value: user['id']?.toString() ?? '');
      await _storage.write(key: AppConstants.kUserRole,  value: user['role']?.toString() ?? '');
      await _storage.write(key: AppConstants.kUserPhone, value: user['phone_number']?.toString() ?? '');
    }
  }

  String _parseError(dynamic e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('400')) return 'Données incorrectes. Vérifiez les informations.';
      if (msg.contains('401')) return 'Code incorrect ou expiré.';
      if (msg.contains('404')) return 'Compte introuvable pour ce numéro.';
      if (msg.contains('429')) return 'Trop de tentatives. Réessayez plus tard.';
      if (msg.contains('SocketException') || msg.contains('Connection')) return 'Pas de connexion internet.';
    }
    return 'Une erreur s\'est produite. Réessayez.';
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).user;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user != null;
});
