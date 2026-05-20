import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────────────────────
final _mockReviews = [
  _Review('AC', 'Aminata Coulibaly', 5.0, 'Réparation fuite robinet', 'Il y a 3 jours',
      'Excellent travail ! Très professionnel, ponctuel et honnête. Je recommande à 100%.'),
  _Review('MT', 'Modibo Traoré', 5.0, 'Installation robinet', 'Il y a 1 semaine',
      'Super efficace, a réglé le problème rapidement. Prix raisonnable.'),
  _Review('SK', 'Seydou Kouyaté', 4.0, 'Chauffe-eau solaire', 'Il y a 2 semaines',
      'Bon travail dans l\'ensemble. Quelques petits détails à améliorer mais globalement satisfait.'),
  _Review('FK', 'Fatoumata Koné', 5.0, 'Remplacement tuyauterie', 'Il y a 3 semaines',
      'Parfait ! Très compétent et soigneux. L\'appartement est resté propre après l\'intervention.'),
  _Review('DB', 'Dramane Ballo', 4.0, 'Réparation chasse d\'eau', 'Il y a 1 mois',
      'Bon artisan. Intervention rapide et efficace.'),
  _Review('MK', 'Mariam Koné', 5.0, 'Installation lave-linge', 'Il y a 1 mois',
      'Impeccable ! Je le recommande vivement. Il explique bien ce qu\'il fait.'),
];

class _Review {
  const _Review(this.initials, this.name, this.rating, this.mission, this.date, this.comment);
  final String initials;
  final String name;
  final double rating;
  final String mission;
  final String date;
  final String comment;
}

// ─────────────────────────────────────────────────────────────────────────────
// ReviewsScreen
// ─────────────────────────────────────────────────────────────────────────────
class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = MockData.currentProvider;
    final avgRating = _mockReviews.fold(0.0, (s, r) => s + r.rating) / _mockReviews.length;

    // Rating distribution
    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _mockReviews) {
      dist[r.rating.toInt()] = (dist[r.rating.toInt()] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surfaceContainerLowest,
            foregroundColor: AppColors.onSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text('Mes Avis', style: AppTypography.h3),
            bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
          ),

          // ── Rating summary card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        // Big rating number
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              StarRating(rating: avgRating, size: 18, showValue: false),
                              const SizedBox(height: 4),
                              Text(
                                '${user.reviewCount} avis',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Distribution bars
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [5, 4, 3, 2, 1].map((stars) {
                              final count = dist[stars] ?? 0;
                              final fraction = _mockReviews.isEmpty
                                  ? 0.0
                                  : count / _mockReviews.length;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      child: Text('$stars',
                                          style: AppTypography.caption.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              letterSpacing: 0)),
                                    ),
                                    const Icon(Icons.star_rounded,
                                        size: 12, color: AppColors.primaryContainer),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: AppRadius.radiusFull,
                                        child: LinearProgressIndicator(
                                          value: fraction,
                                          backgroundColor: AppColors.outlineVariant,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            stars >= 4
                                                ? AppColors.success
                                                : stars == 3
                                                    ? AppColors.warning
                                                    : AppColors.error,
                                          ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 20,
                                      child: Text(
                                        '$count',
                                        style: AppTypography.caption.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                            letterSpacing: 0),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Trust score banner
                  Container(
                    padding: AppSpacing.cardPadding,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        TrustScoreIndicator(score: user.trustScore, size: 52),
                        const SizedBox(width: AppSpacing.compact),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Excellent Trust Score',
                                style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Basé sur votre historique de missions, vos avis et votre profil vérifié.',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: '${_mockReviews.length} avis clients',
                    actionLabel: 'Filtrer',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.compact),
                ],
              ),
            ),
          ),

          // ── Review list ──────────────────────────────────────────────
          _mockReviews.isEmpty
              ? SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.star_outline_rounded,
                    title: 'Aucun avis encore',
                    subtitle: 'Les avis de vos clients apparaîtront ici.',
                  ),
                )
              : SliverList.separated(
                  itemCount: _mockReviews.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: AppSpacing.marginMobile,
                          endIndent: AppSpacing.marginMobile),
                  itemBuilder: (_, i) => _ReviewTile(review: _mockReviews[i]),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.generous)),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatefulWidget {
  const _ReviewTile({required this.review});
  final _Review review;

  @override
  State<_ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<_ReviewTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final isLong = r.comment.length > 100;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile, vertical: AppSpacing.compact),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(initials: r.initials, size: 40),
              const SizedBox(width: AppSpacing.compact),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(r.name,
                              style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700)),
                        ),
                        const Spacer(),
                        Text(r.date, style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      StarRating(rating: r.rating, size: 12, showValue: false),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: AppRadius.radiusFull,
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Text(r.mission,
                            style: AppTypography.overline.copyWith(
                                color: AppColors.onSurfaceVariant, fontSize: 9, letterSpacing: 0.2)),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: isLong ? () => setState(() => _expanded = !_expanded) : null,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Text(
                r.comment,
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant, height: 1.5),
                maxLines: _expanded ? null : 3,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Voir moins' : 'Lire la suite',
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
