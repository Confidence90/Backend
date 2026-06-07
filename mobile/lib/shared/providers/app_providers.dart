import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../../core/services/api_client.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ASYNC STATE WRAPPER
// ═════════════════════════════════════════════════════════════════════════════
sealed class AppAsync<T> {
  const AppAsync();
}

final class AppLoading<T> extends AppAsync<T> {
  const AppLoading();
}

final class AppData<T> extends AppAsync<T> {
  const AppData(this.value);
  final T value;
}

final class AppError<T> extends AppAsync<T> {
  const AppError(this.message, {this.canRetry = true});
  final String message;
  final bool canRetry;
}

// ═════════════════════════════════════════════════════════════════════════════
// MARKETPLACE PROVIDER
// ═════════════════════════════════════════════════════════════════════════════

// Search state
class SearchState {
  const SearchState({
    this.query = '',
    this.category,
    this.filters = const {},
    this.minRating = 0,
    this.maxDistance = 30,
    this.priceMin = 0,
    this.priceMax = 50000,
    this.verifiedOnly = false,
    this.availableNow = false,
    this.sortBy = 'rating',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  final String query;
  final String? category;
  final Set<String> filters;
  final double minRating;
  final double maxDistance;
  final int priceMin;
  final int priceMax;
  final bool verifiedOnly;
  final bool availableNow;
  final String sortBy;
  final List<User> results;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  SearchState copyWith({
    String? query,
    String? category,
    Set<String>? filters,
    double? minRating,
    double? maxDistance,
    int? priceMin,
    int? priceMax,
    bool? verifiedOnly,
    bool? availableNow,
    String? sortBy,
    List<User>? results,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) =>
      SearchState(
        query: query ?? this.query,
        category: category ?? this.category,
        filters: filters ?? this.filters,
        minRating: minRating ?? this.minRating,
        maxDistance: maxDistance ?? this.maxDistance,
        priceMin: priceMin ?? this.priceMin,
        priceMax: priceMax ?? this.priceMax,
        verifiedOnly: verifiedOnly ?? this.verifiedOnly,
        availableNow: availableNow ?? this.availableNow,
        sortBy: sortBy ?? this.sortBy,
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => SearchState(results: _mockResults);

  static final _mockResults = MockData.topArtisans;

  Future<void> search(String query) async {
    state = state.copyWith(query: query, isLoading: true, error: null, page: 1);
    await Future.delayed(const Duration(milliseconds: 400));
    final filtered = _mockResults.where((a) {
      if (query.isEmpty) return true;
      return a.name.toLowerCase().contains(query.toLowerCase()) ||
          (a.specialty?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
    state = state.copyWith(results: filtered, isLoading: false, hasMore: false);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: false, hasMore: false);
  }

  void setCategory(String? category) =>
      state = state.copyWith(category: category);
  void setFilter(String filter, bool active) {
    final filters = {...state.filters};
    if (active)
      filters.add(filter);
    else
      filters.remove(filter);
    state = state.copyWith(filters: filters);
  }

  void setRating(double r) => state = state.copyWith(minRating: r);
  void setDistance(double d) => state = state.copyWith(maxDistance: d);
  void setSortBy(String s) => state = state.copyWith(sortBy: s);
  void resetFilters() => state = SearchState(results: _mockResults);
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);

// Favorites
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});
  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool isFavorited(String id) => state.contains(id);
}

final favoriteArtisansProvider = Provider<List<User>>((ref) {
  final ids = ref.watch(favoritesProvider);
  return MockData.topArtisans.where((a) => ids.contains(a.id)).toList();
});

// ═════════════════════════════════════════════════════════════════════════════
// MISSIONS PROVIDER
// ═════════════════════════════════════════════════════════════════════════════
enum MissionTab { active, upcoming, completed, cancelled }

class MissionsState {
  const MissionsState({
    this.tab = MissionTab.active,
    this.missions = const [],
    this.isLoading = false,
    this.error,
  });
  final MissionTab tab;
  final List<Mission> missions;
  final bool isLoading;
  final String? error;

  MissionsState copyWith({
    MissionTab? tab,
    List<Mission>? missions,
    bool? isLoading,
    String? error,
  }) =>
      MissionsState(
        tab: tab ?? this.tab,
        missions: missions ?? this.missions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class MissionsNotifier extends Notifier<MissionsState> {
  @override
  MissionsState build() {
    _load();
    return const MissionsState(isLoading: true);
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      missions: MockData.activeMissions,
      isLoading: false,
    );
  }

  void setTab(MissionTab tab) {
    state = state.copyWith(tab: tab);
    _loadForTab(tab);
  }

  Future<void> _loadForTab(MissionTab tab) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    final mocks = switch (tab) {
      MissionTab.active => MockData.activeMissions,
      MissionTab.upcoming => MockData.activeMissions.take(1).toList(),
      MissionTab.completed => MockData.activeMissions,
      MissionTab.cancelled => <Mission>[],
    };
    state = state.copyWith(missions: mocks, isLoading: false);
  }

  Future<void> refresh() async => _load();

  Future<void> completeMission(String id) async {
    // Optimistic update
    final updated = state.missions
        .map((m) =>
            m.id == id ? m.copyWith(status: MissionStatusType.completed) : m)
        .toList();
    state = state.copyWith(missions: updated);
    try {
      await ref.read(dioProvider).post('/missions/$id/complete/');
    } catch (_) {
      // Revert on error
      state = state.copyWith(missions: state.missions);
    }
  }
}

final missionsProvider =
    NotifierProvider<MissionsNotifier, MissionsState>(MissionsNotifier.new);

// Active missions count badge
final activeMissionsCountProvider = Provider<int>((ref) {
  final state = ref.watch(missionsProvider);
  return state.missions
      .where((m) => m.status == MissionStatusType.inProgress)
      .length;
});

// ═════════════════════════════════════════════════════════════════════════════
// WALLET PROVIDER
// ═════════════════════════════════════════════════════════════════════════════
class WalletState {
  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });
  final Wallet? wallet;
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  WalletState copyWith({
    Wallet? wallet,
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) =>
      WalletState(
        wallet: wallet ?? this.wallet,
        transactions: transactions ?? this.transactions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() {
    _load();
    return const WalletState(isLoading: true);
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      wallet: MockData.providerWallet,
      transactions: MockData.recentTransactions,
      isLoading: false,
    );
  }

  Future<void> refresh() async => _load();

  Future<void> loadMoreTransactions() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      transactions: [...state.transactions, ...MockData.recentTransactions],
      isLoading: false,
      hasMore: false,
    );
  }

  Future<bool> initiateWithdrawal(int amount, String method) async {
    try {
      await ref.read(dioProvider).post('/wallet/withdraw/', data: {
        'amount': amount,
        'method': method,
      });
      await _load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final walletProvider =
    NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS PROVIDER
// ═════════════════════════════════════════════════════════════════════════════
final _mockNotifications = [
  const AppNotification(
    id: 'n1',
    title: 'Paiement reçu 🎉',
    body: 'Aminata C. vous a payé 25 000 FCFA pour la mission de ce matin.',
    category: NotificationCategory.payment,
    isRead: false,
    createdAt: '2025-05-14T14:32:00Z',
    actionRoute: '/wallet',
  ),
  const AppNotification(
    id: 'n2',
    title: 'Nouvelle mission disponible',
    body: 'Un client cherche un plombier à ACI 2000. Budget : 30 000 FCFA',
    category: NotificationCategory.mission,
    isRead: false,
    createdAt: '2025-05-14T10:00:00Z',
    actionRoute: '/search',
  ),
  const AppNotification(
    id: 'n3',
    title: 'Nouvel avis 5 étoiles ⭐',
    body: 'Modibo T. vous a laissé un excellent avis. Score → 4.8',
    category: NotificationCategory.review,
    isRead: true,
    createdAt: '2025-05-13T16:45:00Z',
  ),
  const AppNotification(
    id: 'n4',
    title: 'Message non lu',
    body: 'Seydou K. : "À quelle heure pouvez-vous venir ?"',
    category: NotificationCategory.message,
    isRead: true,
    createdAt: '2025-05-12T09:30:00Z',
    actionRoute: '/chat/conv-004',
  ),
  const AppNotification(
    id: 'n5',
    title: 'Profil vérifié ✅',
    body:
        'Votre identité a été vérifiée. Votre badge Vérifié est maintenant actif.',
    category: NotificationCategory.system,
    isRead: true,
    createdAt: '2025-05-10T08:00:00Z',
  ),
];

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => _mockNotifications;

  void markRead(String id) {
    state =
        state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
        NotificationsNotifier.new);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});

// ═════════════════════════════════════════════════════════════════════════════
// MESSAGING PROVIDER
// ═════════════════════════════════════════════════════════════════════════════
class MessagingState {
  const MessagingState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  MessagingState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) =>
      MessagingState(
        conversations: conversations ?? this.conversations,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class MessagingNotifier extends Notifier<MessagingState> {
  @override
  MessagingState build() {
    _load();
    return const MessagingState(isLoading: true);
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 400));
    state = MessagingState(
      isLoading: false,
      conversations: MockData.topArtisans
          .take(3)
          .map((a) => Conversation(
                id: 'conv-${a.id}',
                otherUser: a,
                unreadCount: a.id == 'art-001' ? 2 : 0,
                missionTitle: 'Réparation plomberie',
              ))
          .toList(),
    );
  }

  Future<void> refresh() async => _load();
}

final messagingProvider =
    NotifierProvider<MessagingNotifier, MessagingState>(MessagingNotifier.new);

final totalUnreadMessagesProvider = Provider<int>((ref) {
  return ref
      .watch(messagingProvider)
      .conversations
      .fold(0, (sum, c) => sum + c.unreadCount);
});

// ═════════════════════════════════════════════════════════════════════════════
// THEME PROVIDER
// ═════════════════════════════════════════════════════════════════════════════
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// ═════════════════════════════════════════════════════════════════════════════
// CONNECTIVITY PROVIDER
// ═════════════════════════════════════════════════════════════════════════════
final isOnlineProvider = StateProvider<bool>((ref) => true);
