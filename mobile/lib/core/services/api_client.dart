import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Secure Storage Provider
// ─────────────────────────────────────────────────────────────────────────────
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Token Repository
// ─────────────────────────────────────────────────────────────────────────────
final tokenRepositoryProvider = Provider<TokenRepository>(
  (ref) => TokenRepository(ref.watch(secureStorageProvider)),
);

class TokenRepository {
  TokenRepository(this._storage);
  final FlutterSecureStorage _storage;

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken, value: access),
      _storage.write(key: AppConstants.keyRefreshToken, value: refresh),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.keyAccessToken),
      _storage.delete(key: AppConstants.keyRefreshToken),
      _storage.delete(key: AppConstants.keyUserId),
      _storage.delete(key: AppConstants.keyUserRole),
    ]);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Interceptor — attaches JWT + handles 401 refresh
// ─────────────────────────────────────────────────────────────────────────────
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenRepository, this._dio);

  final TokenRepository _tokenRepository;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenRepository.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    options.headers['X-Client'] = 'BaaraLink-Android/1.0.0';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _tokenRepository.getRefreshToken();
        if (refreshToken == null) {
          await _tokenRepository.clearTokens();
          handler.next(err);
          return;
        }

        final response = await _dio.post(
          '${AppConstants.baseUrl}/auth/token/refresh/',
          data: {'refresh': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final newAccess = response.data['access'] as String;
        await _tokenRepository.saveTokens(
          access: newAccess,
          refresh: refreshToken,
        );

        // Retry original request
        final retried = await _dio.request(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: {...err.requestOptions.headers, 'Authorization': 'Bearer $newAccess'},
          ),
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );
        handler.resolve(retried);
      } catch (_) {
        await _tokenRepository.clearTokens();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logging Interceptor (dev only)
// ─────────────────────────────────────────────────────────────────────────────
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[API ERROR] ${err.response?.statusCode} ${err.message}');
    if (err.response?.data != null) {
       // ignore: avoid_print
       print('[API DATA] ${err.response?.data}');
    }
    handler.next(err);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// API Client Provider
// ─────────────────────────────────────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  final tokenRepo = ref.watch(tokenRepositoryProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(tokenRepo, dio),
  ]);

  return dio;
});

// ─────────────────────────────────────────────────────────────────────────────
// API Exception — normalized error types
// ─────────────────────────────────────────────────────────────────────────────
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

final class NetworkException extends ApiException {
  const NetworkException() : super('Pas de connexion internet. Vérifie ton réseau.');
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Session expirée. Reconnecte-toi.');
}

final class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

final class ValidationException extends ApiException {
  const ValidationException(super.message, {this.fieldErrors});
  final Map<String, List<String>>? fieldErrors;
}

final class ServerException extends ApiException {
  const ServerException() : super('Erreur serveur. Réessaie dans un moment.');
}

final class UnknownException extends ApiException {
  const UnknownException() : super('Une erreur inattendue s\'est produite.');
}

// ─────────────────────────────────────────────────────────────────────────────
// Error handler utility
// ─────────────────────────────────────────────────────────────────────────────
ApiException handleDioError(DioException error) {
  if (error.type == DioExceptionType.badResponse) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final dynamic data = response?.data;

    String extractMessage(dynamic data, String fallback) {
      if (data is Map) {
        return data['detail']?.toString() ?? 
               data['message']?.toString() ?? 
               data['error']?.toString() ?? 
               fallback;
      }
      if (data is String && data.isNotEmpty && !data.contains('<!DOCTYPE')) {
        return data;
      }
      return fallback;
    }

    switch (statusCode) {
      case 401:
        return const UnauthorizedException();
      case 404:
        return NotFoundException(extractMessage(data, 'Ressource introuvable.'));
      case 400:
      case 422:
        Map<String, List<String>>? fieldErrors;
        if (data is Map) {
          fieldErrors = {};
          data.forEach((key, value) {
            if (value is List) {
              fieldErrors![key.toString()] = value.map((e) => e.toString()).toList();
            } else if (value != null) {
              fieldErrors![key.toString()] = [value.toString()];
            }
          });
        }
        return ValidationException(
          extractMessage(data, 'Données invalides.'),
          fieldErrors: fieldErrors,
        );
      case 500:
      case 502:
      case 503:
        return const ServerException();
      default:
        return UnknownException();
    }
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.connectionError =>
      const NetworkException(),
    _ => const UnknownException(),
  };
}
