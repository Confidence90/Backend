import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/inputs/app_inputs.dart';
import '../../../core/widgets/layout/app_layout.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/navigation/app_routes.dart';

class ClientDashboardScreen extends ConsumerStatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  ConsumerState<ClientDashboardScreen> createState() =>
      _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends ConsumerState<ClientDashboardScreen> {
  int _navIndex = 0;

  final _categories = const [
    (Icons.plumbing_rounded, 'Plomberie', 'plomberie'),
    (Icons.bolt_rounded, 'Électricité', 'electricite'),
    (Icons.cleaning_services_rounded, 'Ménage', 'menage'),
    (Icons.construction_rounded, 'Maçon', 'macon'),
    (Icons.format_paint_rounded, 'Peinture', 'peinture'),
    (Icons.carpenter_rounded, 'Menuiserie', 'menuiserie'),
    (Icons.yard_rounded, 'Jardinage', 'jardinage'),
    (Icons.child_care_rounded, 'Garde enfant', 'garde_enfant'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentClient;
    final artisans = MockData.topArtisans;

    return AppScaffold(
      topBar: _ClientTopBar(user: user),
      bottomNav: ClientBottomNav(currentIndex: _navIndex, onTap: _onNavTap),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 800)),
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.generous,
          ),
          children: [
            // ── Search Bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 0),
              child: SearchField(
                readOnly: true,
                onTap: () => context.push(AppRoutes.search),
                onFilterTap: () => context.push(AppRoutes.search),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Service Categories ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: SectionHeader(title: 'Services populaires'),
            ),
            const SizedBox(height: AppSpacing.compact),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.compact),
                    child: _CategoryTile(
                      icon: cat.$1,
                      label: cat.$2,
                      onTap: () => context.push('${AppRoutes.search}?category=${cat.$3}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Premium Pack Banner ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: _PremiumPackBanner(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Top Artisans Near You ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: SectionHeader(
                title: 'Top Artisans près de toi',
                actionLabel: 'Voir tout',
                onAction: () => context.push(AppRoutes.search),
              ),
            ),
            const SizedBox(height: AppSpacing.compact),
            ...artisans.take(3).map(
                  (a) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: AppSpacing.xs),
                    child: _ArtisanListTile(artisan: a),
                  ),
                ),

            const SizedBox(height: AppSpacing.lg),

            // ── Quick Actions ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: SectionHeader(title: 'Actions rapides'),
            ),
            const SizedBox(height: AppSpacing.compact),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_task_rounded,
                      label: 'Publier une mission',
                      color: AppColors.primary,
                      bgColor: AppColors.surfaceContainer,
                      onTap: () => context.push(AppRoutes.postMission),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Pack Premium',
                      color: AppColors.primaryContainer,
                      bgColor: AppColors.surfaceContainerHighest,
                      onTap: () => context.push(AppRoutes.packs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: context.push(AppRoutes.search);
      case 2: context.push(AppRoutes.postMission);
      case 3: context.push(AppRoutes.chatList);
      case 4: context.push(AppRoutes.profile);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client Top Bar
// ─────────────────────────────────────────────────────────────────────────────
class _ClientTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _ClientTopBar({required this.user});
  final User user;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.topBarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Bonjour 👋',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                    Text(user.name,
                        style: AppTypography.h3.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () => context.push(AppRoutes.notifications),
                    iconSize: 22,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: AppAvatar(
                  initials: _initials(user.name),
                  size: 36,
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: AppColors.tertiary,
                  borderColor: AppColors.tertiaryContainer,
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
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Tile
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryTile extends StatefulWidget {
  const _CategoryTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: _ctrl.reverse,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(widget.icon, size: 26, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Pack Banner
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumPackBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.packs),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF5500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.radiusLg,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: AppSpacing.compact),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PACK PREMIUM',
                      style: AppTypography.overline.copyWith(
                          color: Colors.white70, letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text('On gère tout pour toi',
                      style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  Text('9 profils sélectionnés dès 6 950 FCFA',
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white60, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Artisan List Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ArtisanListTile extends StatelessWidget {
  const _ArtisanListTile({required this.artisan});
  final User artisan;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/artisan/${artisan.id}'),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            AppAvatar(
              initials: _initials(artisan.name),
              size: AppSpacing.avatarMd,
              showVerified: artisan.isVerified,
              showOnline: !artisan.isVerified,
            ),
            const SizedBox(width: AppSpacing.compact),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(artisan.name,
                            style: AppTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      if (artisan.isPremium) const PremiumBadge(label: 'Top', small: true)
                      else if (artisan.isVerified) const VerifiedBadge(small: true),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${artisan.specialty} • ${artisan.location}',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRating(rating: artisan.rating, size: 12, showValue: true, showCount: true, count: artisan.reviewCount),
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: AppColors.outlineVariant, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Icon(Icons.task_alt_rounded, size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('${artisan.completedMissions} missions',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: Text('Disponible',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Action Card
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}
