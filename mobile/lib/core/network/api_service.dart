import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

// ─── API Client ──────────────────────────────────────────────────────────────
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // JWT Auth Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.kAccessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Auto-refresh token on 401
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry original request
              final token = await _storage.read(key: AppConstants.kAccessToken);
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refresh = await _storage.read(key: AppConstants.kRefreshToken);
      if (refresh == null) return false;
      final resp = await Dio().post(
        '${AppConstants.apiBaseUrl}/auth/token/refresh/',
        data: {'refresh': refresh},
      );
      final newAccess = resp.data['access'] as String?;
      if (newAccess != null) {
        await _storage.write(key: AppConstants.kAccessToken, value: newAccess);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Dio get dio => _dio;
}

// ─── API Service ─────────────────────────────────────────────────────────────
class ApiService {
  final _client = ApiClient().dio;

  // Auth
  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final r = await _client.post('/auth/login/', data: {'phone_number': phone});
    return r.data;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code, {String purpose = 'login'}) async {
    final r = await _client.post('/auth/login/verify/', data: {
      'phone_number': phone, 'code': code, 'purpose': purpose,
    });
    return r.data;
  }

  Future<Map<String, dynamic>> registerRequest(Map<String, dynamic> data) async {
    final r = await _client.post('/auth/register/', data: data);
    return r.data;
  }

  Future<Map<String, dynamic>> registerVerify(String phone, String code) async {
    final r = await _client.post('/auth/register/verify/', data: {
      'phone_number': phone, 'code': code, 'purpose': 'register',
    });
    return r.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final r = await _client.get('/auth/me/');
    return r.data;
  }

  // Jobs
  Future<Map<String, dynamic>> getJobs({
    String? city, String? category, String? urgency,
    String? status, int page = 1,
  }) async {
    final r = await _client.get('/jobs/', queryParameters: {
      if (city != null) 'city': city,
      if (category != null) 'category': category,
      if (urgency != null) 'urgency': urgency,
      if (status != null) 'status': status,
      'page': page,
      'page_size': AppConstants.pageSize,
    });
    return r.data;
  }

  Future<Map<String, dynamic>> getJobDetail(String id) async {
    final r = await _client.get('/jobs/$id/');
    return r.data;
  }

  Future<Map<String, dynamic>> createJob(Map<String, dynamic> data) async {
    final r = await _client.post('/jobs/', data: data);
    return r.data;
  }

  Future<Map<String, dynamic>> applyToJob(String jobId, Map<String, dynamic> data) async {
    final r = await _client.post('/jobs/$jobId/apply/', data: data);
    return r.data;
  }

  Future<void> completeJob(String jobId) async {
    await _client.patch('/jobs/$jobId/complete/');
  }

  // Profiles
  Future<Map<String, dynamic>> getProfiles({
    String? city, String? category, double? lat, double? lng,
    double? radiusKm, int page = 1,
  }) async {
    final r = await _client.get('/profiles/', queryParameters: {
      if (city != null) 'city': city,
      if (category != null) 'category': category,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radiusKm != null) 'radius_km': radiusKm,
      'page': page,
    });
    return r.data;
  }

  Future<Map<String, dynamic>> getProfileDetail(String id) async {
    final r = await _client.get('/profiles/$id/');
    return r.data;
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final r = await _client.get('/profiles/me/');
    return r.data;
  }

  Future<Map<String, dynamic>> updateMyProfile(Map<String, dynamic> data) async {
    final r = await _client.patch('/profiles/me/', data: data);
    return r.data;
  }

  Future<List<dynamic>> getCategories() async {
    final r = await _client.get('/profiles/categories/');
    return r.data;
  }

  // Matching
  Future<Map<String, dynamic>> getRecommendations({
    String? category, String? city, double? lat, double? lng, int topN = 5,
  }) async {
    final r = await _client.get('/matching/recommendations/', queryParameters: {
      if (category != null) 'category': category,
      if (city != null) 'city': city,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'top_n': topN,
    });
    return r.data;
  }

  // Reviews
  Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    final r = await _client.post('/reviews/', data: data);
    return r.data;
  }

  // Notifications
  Future<Map<String, dynamic>> getNotifications() async {
    final r = await _client.get('/notifications/');
    return r.data;
  }

  Future<void> markNotificationRead(String id) async {
    await _client.patch('/notifications/$id/read/');
  }

  Future<void> markAllNotificationsRead() async {
    await _client.patch('/notifications/read-all/');
  }
}

  // Reviews (added)
  Future<List<Map<String, dynamic>>> getReviews({String? revieweeId, String? jobId}) async {
    final r = await _client.get('/reviews/', queryParameters: {
      if (revieweeId != null) 'reviewee': revieweeId,
      if (jobId != null) 'job': jobId,
    });
    final data = r.data;
    return (data is Map ? (data['results'] ?? []) : data).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    final r = await _client.post('/reviews/', data: data);
    return r.data;
  }
