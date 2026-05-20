import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/navigation/app_routes.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteArtisansProvider);
    // Seed some favorites for demo
    final displayList = favorites.isEmpty ? MockData.topArtisans.take(2).toList() : favorites;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          color: AppColors.onSurface,
        ),
        title: Text('Mes Favoris', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
            color: AppColors.onSurfaceVariant,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: displayList.isEmpty
          ? EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'Aucun favori',
              subtitle: 'Ajoutez des prestataires à vos favoris pour les retrouver rapidement.',
              actionLabel: 'Découvrir des artisans',
              onAction: () => context.push(AppRoutes.search),
            )
          : Column(
              children: [
                // Count banner
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
                  color: AppColors.surfaceContainerHighest,
                  child: Row(children: [
                    const Icon(Icons.favorite_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Text('${displayList.length} artisan${displayList.length > 1 ? 's' : ''} sauvegardé${displayList.length > 1 ? 's' : ''}',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  ]),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.marginMobile),
                    itemCount: displayList.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _FavoriteCard(
                        artisan: displayList[i],
                        onRemove: () => ref.read(favoritesProvider.notifier).toggle(displayList[i].id),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FavoriteCard extends StatefulWidget {
  const _FavoriteCard({required this.artisan, required this.onRemove});
  final User artisan;
  final VoidCallback onRemove;

  @override
  State<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<_FavoriteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.artisan;
    return Dismissible(
      key: ValueKey(a.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: AppRadius.radiusLg,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.favorite_border_rounded, color: AppColors.error, size: 24),
          const SizedBox(height: 4),
          Text('Retirer', style: AppTypography.caption.copyWith(
              color: AppColors.error, letterSpacing: 0)),
        ]),
      ),
      onDismissed: (_) => widget.onRemove(),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: _ctrl.reverse,
        onTap: () => context.push('/artisan/${a.id}'),
        child: AnimatedBuilder(
          animation: _scale,
          builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AppAvatar(
                      initials: _initials(a.name),
                      size: AppSpacing.avatarMd,
                      showVerified: a.isVerified,
                    ),
                    const SizedBox(width: AppSpacing.compact),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(child: Text(a.name,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 6),
                            if (a.isPremium) const PremiumBadge(small: true)
                            else if (a.isVerified) const VerifiedBadge(small: true),
                          ]),
                          const SizedBox(height: 2),
                          Text('${a.specialty ?? 'Prestataire'} • ${a.location ?? 'Bamako'}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          StarRating(
                            rating: a.rating, size: 12,
                            showValue: true, showCount: true, count: a.reviewCount,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: AppColors.error),
                      onPressed: widget.onRemove,
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // Skills row
                if (a.skills != null && a.skills!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 26,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: a.skills!.length.clamp(0, 3),
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: AppRadius.radiusFull,
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Text(a.skills![i],
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.compact),
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => context.push('/artisan/${a.id}'),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Center(child: Text('Voir le profil',
                            style: AppTypography.bodySmall.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/chat/conv-${a.id}'),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 16, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ]),
              ],
            ),
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
