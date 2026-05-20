import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';

// ─── Jobs List State ──────────────────────────────────────────────────────────
class JobsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Map<String, dynamic>> jobs;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final String? error;
  final String? selectedCategory;
  final String? selectedCity;
  final String? selectedUrgency;
  final String? selectedStatus;

  const JobsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.jobs = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.error,
    this.selectedCategory,
    this.selectedCity,
    this.selectedUrgency,
    this.selectedStatus,
  });

  JobsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Map<String, dynamic>>? jobs,
    int? totalCount,
    int? currentPage,
    bool? hasMore,
    String? error,
    String? selectedCategory,
    String? selectedCity,
    String? selectedUrgency,
    String? selectedStatus,
  }) =>
      JobsState(
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        jobs: jobs ?? this.jobs,
        totalCount: totalCount ?? this.totalCount,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        error: error,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        selectedCity: selectedCity ?? this.selectedCity,
        selectedUrgency: selectedUrgency ?? this.selectedUrgency,
        selectedStatus: selectedStatus ?? this.selectedStatus,
      );
}

class JobsNotifier extends StateNotifier<JobsState> {
  final _api = ApiService();
  JobsNotifier() : super(const JobsState());

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    try {
      final data = await _api.getJobs(
        city: state.selectedCity,
        category: state.selectedCategory,
        urgency: state.selectedUrgency,
        status: state.selectedStatus,
        page: 1,
      );
      final results = (data['results'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(
        isLoading: false,
        jobs: results,
        totalCount: data['count'] as int? ?? results.length,
        hasMore: data['next'] != null,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erreur de chargement.');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final data = await _api.getJobs(
        city: state.selectedCity,
        category: state.selectedCategory,
        urgency: state.selectedUrgency,
        status: state.selectedStatus,
        page: nextPage,
      );
      final more = (data['results'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(
        isLoadingMore: false,
        jobs: [...state.jobs, ...more],
        hasMore: data['next'] != null,
        currentPage: nextPage,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void applyFilter({
    String? city,
    String? category,
    String? urgency,
    String? status,
    bool clear = false,
  }) {
    if (clear) {
      state = const JobsState();
    } else {
      state = state.copyWith(
        selectedCity: city,
        selectedCategory: category,
        selectedUrgency: urgency,
        selectedStatus: status,
      );
    }
    load();
  }
}

// ─── Job Detail State ─────────────────────────────────────────────────────────
class JobDetailState {
  final bool isLoading;
  final bool isApplying;
  final bool isCompleting;
  final Map<String, dynamic>? job;
  final String? error;
  final String? successMessage;

  const JobDetailState({
    this.isLoading = false,
    this.isApplying = false,
    this.isCompleting = false,
    this.job,
    this.error,
    this.successMessage,
  });

  JobDetailState copyWith({
    bool? isLoading,
    bool? isApplying,
    bool? isCompleting,
    Map<String, dynamic>? job,
    String? error,
    String? successMessage,
  }) =>
      JobDetailState(
        isLoading: isLoading ?? this.isLoading,
        isApplying: isApplying ?? this.isApplying,
        isCompleting: isCompleting ?? this.isCompleting,
        job: job ?? this.job,
        error: error,
        successMessage: successMessage,
      );
}

class JobDetailNotifier extends StateNotifier<JobDetailState> {
  final _api = ApiService();
  final String jobId;

  JobDetailNotifier(this.jobId) : super(const JobDetailState()) {
    fetchJob();
  }

  Future<void> fetchJob() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.getJobDetail(jobId);
      state = state.copyWith(isLoading: false, job: data);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Impossible de charger cette mission.');
    }
  }

  Future<bool> apply({String? coverLetter, int? proposedPrice}) async {
    state = state.copyWith(isApplying: true, error: null, successMessage: null);
    try {
      await _api.applyToJob(jobId, {
        if (coverLetter != null && coverLetter.isNotEmpty) 'cover_letter': coverLetter,
        if (proposedPrice != null) 'proposed_price': proposedPrice,
      });
      state = state.copyWith(
        isApplying: false,
        successMessage: 'Candidature envoyée avec succès ! 🎉',
      );
      await fetchJob();
      return true;
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        error: 'Impossible de postuler. Vérifiez votre profil.',
      );
      return false;
    }
  }

  Future<bool> complete() async {
    state = state.copyWith(isCompleting: true, error: null);
    try {
      await _api.completeJob(jobId);
      state = state.copyWith(
        isCompleting: false,
        successMessage: 'Mission marquée terminée !',
      );
      await fetchJob();
      return true;
    } catch (_) {
      state = state.copyWith(isCompleting: false, error: 'Erreur lors de la mise à jour.');
      return false;
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final jobsProvider = StateNotifierProvider<JobsNotifier, JobsState>(
  (ref) => JobsNotifier()..load(),
);

final jobDetailProvider = StateNotifierProvider.family<JobDetailNotifier, JobDetailState, String>(
  (ref, jobId) => JobDetailNotifier(jobId),
);
