import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/jobs_provider.dart';
import '../widgets/job_card.dart';

class JobsListPage extends ConsumerStatefulWidget {
  const JobsListPage({super.key});
  @override
  ConsumerState<JobsListPage> createState() => _JobsListPageState();
}

class _JobsListPageState extends ConsumerState<JobsListPage> {
  final _searchCtrl  = TextEditingController();
  final _scrollCtrl  = ScrollController();
  String? _urgency;
  String? _jobType;
  bool _filtersOpen  = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(jobsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(jobsProvider.notifier).applyFilter(
      urgency: _urgency,
      status: 'open',
    );
    setState(() => _filtersOpen = false);
  }

  void _clearFilters() {
    setState(() { _urgency = null; _jobType = null; });
    ref.read(jobsProvider.notifier).applyFilter(clear: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Missions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => setState(() => _filtersOpen = !_filtersOpen),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary,
            onPressed: () => context.push(AppRoutes.jobCreate),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + filters panel ──
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une mission…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref.read(jobsProvider.notifier).load(refresh: true);
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => ref.read(jobsProvider.notifier).load(refresh: true),
                  ),
                ),

                // Expandable filters
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildFiltersPanel(),
                  crossFadeState: _filtersOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),

                // Active filters chips
                if (_urgency != null || _jobType != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        const Text('Filtres actifs :', style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondary,
                        )),
                        const SizedBox(width: 8),
                        if (_urgency != null) _ActiveFilterChip(
                          label: _urgency!,
                          onRemove: () { setState(() => _urgency = null); _applyFilters(); },
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: _clearFilters,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Effacer tout', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 1),
              ],
            ),
          ),

          // ── Results count ──
          if (!state.isLoading)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${state.totalCount} mission${state.totalCount > 1 ? 's' : ''} trouvée${state.totalCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 13,
                      fontWeight: FontWeight.w500, color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // ── List ──
          Expanded(
            child: state.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: JobCardSkeleton(),
                    ),
                  )
                : state.error != null
                    ? NetworkErrorWidget(onRetry: () => ref.read(jobsProvider.notifier).load())
                    : state.jobs.isEmpty
                        ? EmptyState(
                            emoji: '📭',
                            title: 'Aucune mission trouvée',
                            subtitle: 'Modifiez vos filtres ou publiez la première mission.',
                            buttonLabel: 'Publier une mission',
                            onAction: () => context.push(AppRoutes.jobCreate),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () => ref.read(jobsProvider.notifier).load(refresh: true),
                            child: ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: state.jobs.length + (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (ctx, i) {
                                if (i == state.jobs.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator(
                                      color: AppColors.primary, strokeWidth: 2,
                                    )),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: JobCard(
                                    job: state.jobs[i],
                                    onTap: () => context.push('/jobs/${state.jobs[i]['id']}'),
                                  ).animate(delay: (i * 40).ms).slideY(begin: 0.08).fade(),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Urgence', style: TextStyle(
            fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(label: 'Urgent',   value: 'high',   selected: _urgency == 'high',   color: AppColors.error,
                onTap: () => setState(() => _urgency = _urgency == 'high' ? null : 'high')),
              _FilterChip(label: 'Sous 48h', value: 'medium', selected: _urgency == 'medium', color: AppColors.warning,
                onTap: () => setState(() => _urgency = _urgency == 'medium' ? null : 'medium')),
              _FilterChip(label: 'Flexible', value: 'low',    selected: _urgency == 'low',    color: AppColors.success,
                onTap: () => setState(() => _urgency = _urgency == 'low' ? null : 'low')),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _clearFilters, child: const Text('Réinitialiser'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: _applyFilters, child: const Text('Appliquer'))),
          ]),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.value, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.12) : AppColors.surfaceVariant,
        borderRadius: AppRadius.full,
        border: Border.all(color: selected ? color : AppColors.border, width: selected ? 1.5 : 1),
      ),
      child: Text(label, style: TextStyle(
        fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
        color: selected ? color : AppColors.textSecondary,
      )),
    ),
  );
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: AppRadius.full,
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.primary)),
      const SizedBox(width: 4),
      GestureDetector(onTap: onRemove, child: const Icon(Icons.close, size: 14, color: AppColors.primary)),
    ]),
  );
}
