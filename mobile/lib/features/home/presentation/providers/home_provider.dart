import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';

class HomeState {
  final bool isLoadingJobs;
  final bool isLoadingCategories;
  final List<Map<String, dynamic>> jobs;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> topProviders;
  final int openJobsCount;
  final int activeProviders;
  final String? error;

  const HomeState({
    this.isLoadingJobs = false,
    this.isLoadingCategories = false,
    this.jobs = const [],
    this.categories = const [],
    this.topProviders = const [],
    this.openJobsCount = 0,
    this.activeProviders = 0,
    this.error,
  });

  HomeState copyWith({
    bool? isLoadingJobs,
    bool? isLoadingCategories,
    List<Map<String, dynamic>>? jobs,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? topProviders,
    int? openJobsCount,
    int? activeProviders,
    String? error,
  }) =>
      HomeState(
        isLoadingJobs: isLoadingJobs ?? this.isLoadingJobs,
        isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
        jobs: jobs ?? this.jobs,
        categories: categories ?? this.categories,
        topProviders: topProviders ?? this.topProviders,
        openJobsCount: openJobsCount ?? this.openJobsCount,
        activeProviders: activeProviders ?? this.activeProviders,
        error: error,
      );
}

class HomeNotifier extends StateNotifier<HomeState> {
  final _api = ApiService();

  HomeNotifier() : super(const HomeState());

  Future<void> load({String? categoryId}) async {
    state = state.copyWith(isLoadingJobs: true, isLoadingCategories: true, error: null);

    await Future.wait([
      _loadCategories(),
      _loadJobs(categoryId: categoryId),
      _loadTopProviders(),
    ]);
  }

  Future<void> filterByCategory(String? categoryId) async {
    state = state.copyWith(isLoadingJobs: true);
    await _loadJobs(categoryId: categoryId);
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _api.getCategories();
      state = state.copyWith(
        isLoadingCategories: false,
        categories: data.cast<Map<String, dynamic>>(),
      );
    } catch (_) {
      state = state.copyWith(isLoadingCategories: false);
    }
  }

  Future<void> _loadJobs({String? categoryId}) async {
    try {
      final data = await _api.getJobs(
        status: 'open',
        category: categoryId,
      );
      final results = (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(
        isLoadingJobs: false,
        jobs: results,
        openJobsCount: data['count'] as int? ?? results.length,
      );
    } catch (_) {
      state = state.copyWith(isLoadingJobs: false);
    }
  }

  Future<void> _loadTopProviders() async {
    try {
      final data = await _api.getRecommendations(city: 'Bamako', topN: 5);
      final results = (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(
        topProviders: results,
        activeProviders: results.length,
      );
    } catch (_) {
      // Silent fail on providers
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);
