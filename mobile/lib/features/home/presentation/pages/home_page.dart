import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import '../providers/home_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeProvider.notifier).load();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user  = ref.watch(currentUserProvider);
    final state = ref.watch(homeProvider);
    final firstName = user?['first_name'] as String? ?? 'ami';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(homeProvider.notifier).load(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ──
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              snap: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: AppRadius.md),
                    child: const Center(child: Text('BL', style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary,
                    ))),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    color: AppColors.textPrimary,
                    onPressed: () => context.push(AppRoutes.notifications),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.profileMe),
                    child: UserAvatar(
                      name: firstName,
                      imageUrl: user?['avatar'] as String?,
                      size: 36,
                    ),
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Greeting ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(firstName),
                          style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 24,
                            fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2,
                          ),
                        ).animate().slideY(begin: 0.2).fade(),
                        const SizedBox(height: 4),
                        const Text(
                          'Que cherchez-vous aujourd\'hui ?',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textSecondary),
                        ).animate(delay: 80.ms).slideY(begin: 0.2).fade(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Search bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.jobList),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadius.lg,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 16),
                            Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                            SizedBox(width: 10),
                            Text('Plombier, électricien, ménage…',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                    ),
                  ).animate(delay: 120.ms).slideY(begin: 0.2).fade(),

                  const SizedBox(height: 24),

                  // ── Stats strip ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _StatChip(label: 'Missions ouvertes', value: '${state.openJobsCount}', icon: '💼'),
                        const SizedBox(width: 12),
                        _StatChip(label: 'Prestataires actifs', value: '${state.activeProviders}', icon: '👷'),
                      ],
                    ),
                  ).animate(delay: 160.ms).fade(),

                  const SizedBox(height: 24),

                  // ── Categories ──
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                    child: SectionHeader(
                      title: 'Catégories',
                      actionLabel: 'Tout voir',
                      onAction: () => context.push(AppRoutes.jobList),
                    ),
                  ),

                  SizedBox(
                    height: 100,
                    child: state.isLoadingCategories
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: state.categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              final cat = state.categories[i];
                              final isSelected = _selectedCategory == cat['id'];
                              return _CategoryChip(
                                name: cat['name'] as String,
                                icon: AppConstants.categoryIcons[cat['slug']] ?? '🔧',
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() => _selectedCategory = isSelected ? null : cat['id'] as String);
                                  ref.read(homeProvider.notifier).filterByCategory(
                                    isSelected ? null : cat['id'] as String);
                                },
                              );
                            },
                          ),
                  ).animate(delay: 200.ms).slideX(begin: 0.1).fade(),

                  const SizedBox(height: 24),

                  // ── Recent jobs ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(
                      title: 'Missions récentes',
                      actionLabel: 'Toutes',
                      onAction: () => context.push(AppRoutes.jobList),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── Jobs list ──
            if (state.isLoadingJobs)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const Padding(padding: EdgeInsets.only(bottom: 12), child: JobCardSkeleton()),
                    childCount: 4,
                  ),
                ),
              )
            else if (state.jobs.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  emoji: '📭',
                  title: 'Aucune mission pour l\'instant',
                  subtitle: 'Les nouvelles missions apparaîtront ici.',
                  buttonLabel: 'Publier une mission',
                  onAction: () => context.push(AppRoutes.jobCreate),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: JobCard(
                        job: state.jobs[i],
                        onTap: () => context.push('/jobs/${state.jobs[i]['id']}'),
                      ),
                    ).animate(delay: (i * 60).ms).slideY(begin: 0.1).fade(),
                    childCount: state.jobs.length > 6 ? 6 : state.jobs.length,
                  ),
                ),
              ),

            // ── Top providers ──
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(title: 'Top prestataires', actionLabel: 'Voir plus', onAction: () {}),
                  ),
                  const SizedBox(height: 12),
                  if (state.topProviders.isNotEmpty)
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: state.topProviders.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) => _ProviderCard(
                          provider: state.topProviders[i],
                          onTap: () => context.push('/profile/${state.topProviders[i]['id']}'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── FAB ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.jobCreate),
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Publier', style: TextStyle(
          fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
        )),
      ).animate(delay: 400.ms).scale(curve: Curves.elasticOut),
    );
  }

  String _getGreeting(String name) {
    final h = DateTime.now().hour;
    final g = h < 12 ? 'Bonjour' : h < 18 ? 'Bon après-midi' : 'Bonsoir';
    return '$g, $name 👋';
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value, icon;
  const _StatChip({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border), boxShadow: AppShadows.subtle),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
        ])),
      ]),
    ),
  );
}

// ── Category Chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String name, icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({required this.name, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 80,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: AppRadius.lg,
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        boxShadow: isSelected ? AppShadows.card : AppShadows.subtle,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(name, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

// ── Provider Card ─────────────────────────────────────────────────────────────
class _ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final VoidCallback onTap;
  const _ProviderCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 130,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border), boxShadow: AppShadows.subtle),
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        UserAvatar(name: provider['user_name'] as String? ?? '?', imageUrl: provider['avatar'] as String?, size: 52,
          isVerified: provider['is_verified'] == true),
        const SizedBox(height: 8),
        Text(provider['user_name'] as String? ?? '',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        RatingStars(rating: (provider['avg_rating'] as num?)?.toDouble() ?? 0, size: 12),
        const SizedBox(height: 4),
        Text('${provider['hourly_rate'] ?? '—'} FCFA/h',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: AppColors.textSecondary)),
      ]),
    ),
  );
}
