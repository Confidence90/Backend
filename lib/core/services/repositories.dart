import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/app_models.dart';
import '../../core/services/api_client.dart';
import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BASE REPOSITORY — shared error handling + pagination
// ─────────────────────────────────────────────────────────────────────────────
abstract class BaseRepository {
  BaseRepository(this.dio);
  final Dio dio;

  Future<T> safeCall<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTH REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────
class AuthRepository extends BaseRepository {
  AuthRepository(super.dio);

  /// POST /api/v1/auth/otp/send/
  Future<void> sendOtp(String phone) => safeCall(() async {
    await dio.post('/auth/otp/send/', data: {'phone': phone});
  });

  /// POST /api/v1/auth/otp/verify/
  Future<AuthTokens> verifyOtp(String phone, String otp) => safeCall(() async {
    final res = await dio.post('/auth/otp/verify/', data: {
      'phone': phone, 'otp': otp,
    });
    return AuthTokens.fromJson(res.data as Map<String, dynamic>);
  });

  /// POST /api/v1/auth/token/
  Future<AuthTokens> loginEmail(String email, String password) => safeCall(() async {
    final res = await dio.post('/auth/token/', data: {
      'email': email, 'password': password,
    });
    return AuthTokens.fromJson(res.data as Map<String, dynamic>);
  });

  /// GET /api/v1/auth/me/
  Future<User> getMe() => safeCall(() async {
    final res = await dio.get('/auth/me/');
    return User.fromJson(res.data as Map<String, dynamic>);
  });

  /// PATCH /api/v1/auth/me/
  Future<User> updateMe(Map<String, dynamic> data) => safeCall(() async {
    final res = await dio.patch('/auth/me/', data: data);
    return User.fromJson(res.data as Map<String, dynamic>);
  });

  /// POST /api/v1/auth/logout/
  Future<void> logout() => safeCall(() async {
    await dio.post('/auth/logout/');
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MARKETPLACE REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────
class MarketplaceRepository extends BaseRepository {
  MarketplaceRepository(super.dio);

  /// GET /api/v1/providers/ — paginated artisan list
  Future<PaginatedResponse<User>> getProviders({
    String? query,
    String? category,
    double? minRating,
    double? maxDistance,
    int? priceMin,
    int? priceMax,
    bool? verifiedOnly,
    bool? availableNow,
    String sortBy = 'rating',
    int page = 1,
  }) => safeCall(() async {
    final res = await dio.get('/providers/', queryParameters: {
      if (query != null && query.isNotEmpty) 'search': query,
      if (category != null) 'category': category,
      if (minRating != null && minRating > 0) 'min_rating': minRating,
      if (maxDistance != null) 'max_distance': maxDistance,
      if (priceMin != null && priceMin > 0) 'price_min': priceMin,
      if (priceMax != null && priceMax < 50000) 'price_max': priceMax,
      if (verifiedOnly == true) 'verified': true,
      if (availableNow == true) 'available_now': true,
      'ordering': sortBy,
      'page': page,
      'page_size': AppConstants.defaultPageSize,
    });
    final data = res.data as Map<String, dynamic>;
    return PaginatedResponse<User>(
      count: data['count'] as int,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results: (data['results'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  });

  /// GET /api/v1/providers/:id/
  Future<User> getProvider(String id) => safeCall(() async {
    final res = await dio.get('/providers/$id/');
    return User.fromJson(res.data as Map<String, dynamic>);
  });

  /// POST /api/v1/favorites/:id/
  Future<void> toggleFavorite(String providerId) => safeCall(() async {
    await dio.post('/favorites/$providerId/');
  });

  /// GET /api/v1/categories/
  Future<List<String>> getCategories() => safeCall(() async {
    final res = await dio.get('/categories/');
    return List<String>.from(res.data as List);
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MISSIONS REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────
class MissionsRepository extends BaseRepository {
  MissionsRepository(super.dio);

  /// GET /api/v1/missions/ — my missions as provider or client
  Future<PaginatedResponse<Mission>> getMyMissions({
    MissionStatusType? status,
    int page = 1,
  }) => safeCall(() async {
    final res = await dio.get('/missions/', queryParameters: {
      if (status != null) 'status': status.name,
      'page': page,
      'page_size': AppConstants.defaultPageSize,
    });
    final data = res.data as Map<String, dynamic>;
    return PaginatedResponse<Mission>(
      count: data['count'] as int,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results: (data['results'] as List)
          .map((e) => Mission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  });

  /// POST /api/v1/missions/
  Future<Mission> createMission(Map<String, dynamic> data) => safeCall(() async {
    final res = await dio.post('/missions/', data: data);
    return Mission.fromJson(res.data as Map<String, dynamic>);
  });

  /// GET /api/v1/missions/:id/
  Future<Mission> getMission(String id) => safeCall(() async {
    final res = await dio.get('/missions/$id/');
    return Mission.fromJson(res.data as Map<String, dynamic>);
  });

  /// POST /api/v1/missions/:id/complete/
  Future<Mission> completeMission(String id, {double? rating, String? review}) =>
      safeCall(() async {
    final res = await dio.post('/missions/$id/complete/', data: {
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
    });
    return Mission.fromJson(res.data as Map<String, dynamic>);
  });

  /// POST /api/v1/missions/:id/cancel/
  Future<void> cancelMission(String id, {String? reason}) => safeCall(() async {
    await dio.post('/missions/$id/cancel/', data: {if (reason != null) 'reason': reason});
  });

  /// POST /api/v1/missions/:id/apply/ — provider applies to mission
  Future<void> applyToMission(String id) => safeCall(() async {
    await dio.post('/missions/$id/apply/');
  });

  /// GET /api/v1/missions/:id/applications/
  Future<List<User>> getMissionApplications(String id) => safeCall(() async {
    final res = await dio.get('/missions/$id/applications/');
    return (res.data as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// WALLET REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────
class WalletRepository extends BaseRepository {
  WalletRepository(super.dio);

  /// GET /api/v1/wallet/
  Future<Wallet> getWallet() => safeCall(() async {
    final res = await dio.get('/wallet/');
    return Wallet.fromJson(res.data as Map<String, dynamic>);
  });

  /// GET /api/v1/wallet/transactions/
  Future<PaginatedResponse<Transaction>> getTransactions({int page = 1}) =>
      safeCall(() async {
    final res = await dio.get('/wallet/transactions/', queryParameters: {
      'page': page,
      'page_size': AppConstants.defaultPageSize,
    });
    final data = res.data as Map<String, dynamic>;
    return PaginatedResponse<Transaction>(
      count: data['count'] as int,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results: (data['results'] as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  });

  /// POST /api/v1/wallet/withdraw/ — Orange Money / Wave withdrawal
  Future<Transaction> withdraw({
    required int amount,
    required String method, // 'orange_money' | 'wave' | 'moov'
    required String phoneNumber,
  }) => safeCall(() async {
    final res = await dio.post('/wallet/withdraw/', data: {
      'amount': amount,
      'method': method,
      'phone': phoneNumber,
    });
    return Transaction.fromJson(res.data as Map<String, dynamic>);
  });

  /// POST /api/v1/payments/ — client pays for mission (escrow)
  Future<Map<String, dynamic>> createPayment({
    required String missionId,
    required int amount,
    required String method,
    required String phone,
  }) => safeCall(() async {
    final res = await dio.post('/payments/', data: {
      'mission': missionId,
      'amount': amount,
      'payment_method': method,
      'phone': phone,
    });
    return res.data as Map<String, dynamic>;
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────
class ChatRepository extends BaseRepository {
  ChatRepository(super.dio);

  /// GET /api/v1/conversations/
  Future<List<Conversation>> getConversations() => safeCall(() async {
    final res = await dio.get('/conversations/');
    return (res.data as List)
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  /// GET /api/v1/conversations/:id/messages/
  Future<PaginatedResponse<ChatMessage>> getMessages(String convId, {int page = 1}) =>
      safeCall(() async {
    final res = await dio.get('/conversations/$convId/messages/', queryParameters: {
      'page': page,
      'page_size': AppConstants.chatPageSize,
    });
    final data = res.data as Map<String, dynamic>;
    return PaginatedResponse<ChatMessage>(
      count: data['count'] as int,
      next: data['next'] as String?,
      previous: data['previous'] as String?,
      results: (data['results'] as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  });

  /// POST /api/v1/conversations/:id/messages/
  Future<ChatMessage> sendMessage(String convId, String content, {MessageType type = MessageType.text}) =>
      safeCall(() async {
    final res = await dio.post('/conversations/$convId/messages/', data: {
      'content': content,
      'type': type.name,
    });
    return ChatMessage.fromJson(res.data as Map<String, dynamic>);
  });

  /// POST /api/v1/conversations/:id/read/
  Future<void> markRead(String convId) => safeCall(() async {
    await dio.post('/conversations/$convId/read/');
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATIONS REPOSITORY
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsRepository extends BaseRepository {
  NotificationsRepository(super.dio);

  /// GET /api/v1/notifications/
  Future<List<AppNotification>> getNotifications() => safeCall(() async {
    final res = await dio.get('/notifications/');
    return (res.data as List)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  /// POST /api/v1/notifications/:id/read/
  Future<void> markRead(String id) => safeCall(() async {
    await dio.post('/notifications/$id/read/');
  });

  /// POST /api/v1/notifications/read-all/
  Future<void> markAllRead() => safeCall(() async {
    await dio.post('/notifications/read-all/');
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository providers
// ─────────────────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>(
  (ref) => MarketplaceRepository(ref.watch(dioProvider)),
);
final missionsRepositoryProvider = Provider<MissionsRepository>(
  (ref) => MissionsRepository(ref.watch(dioProvider)),
);
final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepository(ref.watch(dioProvider)),
);
final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(dioProvider)),
);
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(ref.watch(dioProvider)),
);
