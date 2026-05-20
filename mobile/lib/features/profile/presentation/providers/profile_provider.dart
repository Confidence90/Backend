import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> reviews;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.profile,
    this.categories = const [],
    this.reviews = const [],
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? reviews,
    String? error,
    String? successMessage,
  }) =>
      ProfileState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        profile: profile ?? this.profile,
        categories: categories ?? this.categories,
        reviews: reviews ?? this.reviews,
        error: error,
        successMessage: successMessage,
      );
}

// ─── My Profile Notifier ──────────────────────────────────────────────────────
class MyProfileNotifier extends StateNotifier<ProfileState> {
  final _api = ApiService();

  MyProfileNotifier() : super(const ProfileState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _api.getMyProfile(),
        _api.getCategories(),
      ]);
      final profile    = results[0] as Map<String, dynamic>;
      final categories = (results[1] as List).cast<Map<String, dynamic>>();
      final reviews    = await _api.getReviews(revieweeId: profile['user'] as String? ?? '');
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        categories: categories,
        reviews: reviews,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Impossible de charger le profil.');
    }
  }

  Future<bool> update(Map<String, dynamic> data) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final updated = await _api.updateMyProfile(data);
      state = state.copyWith(
        isSaving: false,
        profile: updated,
        successMessage: 'Profil mis à jour avec succès.',
      );
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false, error: 'Erreur lors de la mise à jour.');
      return false;
    }
  }

  Future<bool> updateAvailability(String status) async {
    return update({'availability': status});
  }
}

// ─── Provider Profile Notifier (read-only, by ID) ─────────────────────────────
class ProviderProfileNotifier extends StateNotifier<ProfileState> {
  final _api = ApiService();
  final String profileId;

  ProviderProfileNotifier(this.profileId) : super(const ProfileState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _api.getProfileDetail(profileId);
      final userId  = profile['user'] as String? ?? '';
      final reviews = userId.isNotEmpty ? await _api.getReviews(revieweeId: userId) : <Map<String, dynamic>>[];
      state = state.copyWith(isLoading: false, profile: profile, reviews: reviews);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Profil introuvable.');
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final myProfileProvider = StateNotifierProvider<MyProfileNotifier, ProfileState>(
  (ref) => MyProfileNotifier(),
);

final providerProfileProvider = StateNotifierProvider.family<ProviderProfileNotifier, ProfileState, String>(
  (ref, id) => ProviderProfileNotifier(id),
);
