import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/navigation/app_routes.dart';

class ArtisanProfileScreen extends ConsumerStatefulWidget {
  const ArtisanProfileScreen({super.key, required this.artisanId});
  final String artisanId;

  @override
  ConsumerState<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorited = false;
  final _fcfa = NumberFormat('#,###', 'fr_FR');
  User? _artisan;

  final _reviews = [
    ('AC', 'Aminata C.', 5.0, 'Il y a 3 jours', 'Excellent travail ! Très professionnel, ponctuel et honnête. Je recommande à 100%.'),
    ('MT', 'Modibo T.', 5.0, 'Il y a 1 semaine', 'Super efficace, a réglé le problème rapidement. Prix raisonnable.'),
    ('SK', 'Seydou K.', 4.0, 'Il y a 2 semaines', 'Bon travail dans l\'ensemble, quelques petits détails à améliorer.'),
  ];

  final _portfolio = [
    'Réparation plomberie salon',
    'Installation chauffe-eau solaire',
    'Rénovation salle de bain',
    'Remplacement tuyauterie',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _artisan = MockData.topArtisans.firstWhere(
      (a) => a.id == widget.artisanId,
      orElse: () => MockData.topArtisans.first,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = _artisan!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero / Collapsing header ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFavorited ? Colors.pink[200] : Colors.white,
                ),
                onPressed: () => setState(() => _isFavorited = !_isFavorited),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFFD06000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.plumbing_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ),
          ),

          // ── Profile Card ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // Avatar + name row (overlapping hero)
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surfaceContainerLowest, width: 3),
                            ),
                            child: AppAvatar(
                              initials: _initials(a.name),
                              size: 76,
                              showVerified: a.isVerified,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.compact),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(a.name,
                                          style: AppTypography.h2.copyWith(fontSize: 20)),
                                    ),
                                    const SizedBox(width: 6),
                                    if (a.isVerified) const VerifiedBadge(),
                                  ],
                                ),
                                Text(
                                  '${a.specialty} • ${a.location}',
                                  style: AppTypography.bodySmall
                                      .copyWith(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.marginMobile, 0, AppSpacing.marginMobile, AppSpacing.md),
                    child: Row(
                      children: [
                        _StatChip(value: a.rating.toStringAsFixed(1), label: 'Note', icon: Icons.star_rounded, color: AppColors.primaryContainer),
                        const SizedBox(width: 8),
                        _StatChip(value: '${a.reviewCount}', label: 'Avis', icon: Icons.chat_bubble_rounded, color: AppColors.tertiary),
                        const SizedBox(width: 8),
                        _StatChip(value: '${a.completedMissions}', label: 'Missions', icon: Icons.task_alt_rounded, color: AppColors.success),
                        const SizedBox(width: 8),
                        TrustScoreIndicator(score: a.trustScore, size: 52),
                      ],
                    ),
                  ),

                  // Certification badge
                  if (a.isCertified && a.certificationBadge != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.marginMobile, 0, AppSpacing.marginMobile, AppSpacing.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                size: 18, color: AppColors.tertiary),
                            const SizedBox(width: 6),
                            Text(a.certificationBadge!,
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.tertiary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),

                  // Skills tags
                  if (a.skills != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.marginMobile, 0, AppSpacing.marginMobile, AppSpacing.md),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: a.skills!
                            .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: AppRadius.radiusFull,
                                    border: Border.all(color: AppColors.outlineVariant),
                                  ),
                                  child: Text(s,
                                      style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                      ),
                    ),

                  // Tabs
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: AppRadius.radiusSm,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1)),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: AppTypography.bodySmall,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'À propos'),
                        Tab(text: 'Portfolio'),
                        Tab(text: 'Avis'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),

          // ── Tab content ───────────────────────────────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AboutTab(artisan: a),
                _PortfolioTab(items: _portfolio),
                _ReviewsTab(reviews: _reviews),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom CTA ────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile, AppSpacing.compact, AppSpacing.marginMobile, AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: const Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PrimaryButton(
                  label: 'Réserver une mission',
                  onPressed: () => context.push(AppRoutes.postMission),
                  icon: const Icon(Icons.add_task_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => context.push('/chat/conv-${a.id}'),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, 2).toUpperCase();
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label, required this.icon, required this.color});
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: AppTypography.overline.copyWith(letterSpacing: 0.3, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.artisan});
  final User artisan;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      children: [
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('À propos', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Professionnel avec 8 ans d\'expérience à Bamako. Spécialiste des fuites, installations sanitaires et chauffe-eau. Disponible 7j/7, intervention rapide garantie. Certifié BaaraLink 2024.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.compact),
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _InfoRow(Icons.location_on_rounded, artisan.location ?? 'Bamako'),
              _InfoRow(Icons.schedule_rounded, 'Disponible maintenant'),
              _InfoRow(Icons.payment_rounded, 'Orange Money • Wave • Espèces'),
              _InfoRow(Icons.language_rounded, 'Français • Bambara'),
              _InfoRow(Icons.verified_rounded, 'Identité vérifiée par BaaraLink'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.plumbing_rounded, size: 40, color: AppColors.primary.withOpacity(0.4)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(items[i],
                  style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant, letterSpacing: 0),
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.reviews});
  final List<(String, String, double, String, String)> reviews;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final r = reviews[i];
        return Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(initials: r.$1, size: 36),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.$2, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                        StarRating(rating: r.$3, size: 11, showValue: false),
                      ],
                    ),
                  ),
                  Text(r.$4, style: AppTypography.caption.copyWith(letterSpacing: 0)),
                ],
              ),
              const SizedBox(height: 8),
              Text(r.$5, style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant, height: 1.5)),
            ],
          ),
        );
      },
    );
  }
}
