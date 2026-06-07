import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? MockData.currentProvider;
    final isProvider = user.role == UserRole.provider;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor: AppColors.surfaceContainerLowest,
            foregroundColor: AppColors.onSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text('Mon Profil', style: AppTypography.h3),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                color: AppColors.primary,
                onPressed: () => context.push(AppRoutes.editProfile),
                tooltip: 'Modifier',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Profile Card ─────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.all(AppSpacing.marginMobile),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.04),
                        AppColors.primary.withOpacity(0.01),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppAvatar(
                            initials: _initials(user.name),
                            size: AppSpacing.avatarXl,
                            showVerified: user.isVerified,
                            borderColor: AppColors.primaryContainer.withOpacity(0.5),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(user.name,
                                          style: AppTypography.h3,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(width: 6),
                                    if (user.isVerified)
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: AppColors.tertiary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.verified_rounded,
                                            color: Colors.white, size: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.specialty ??
                                      (isProvider ? 'Prestataire' : 'Client'),
                                  style: AppTypography.bodySmall
                                      .copyWith(color: AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(height: 2),
                                Row(children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 12, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 3),
                                  Text(user.location ?? 'Bamako, Mali',
                                      style: AppTypography.caption.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          letterSpacing: 0)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Stats row
                      if (isProvider) ...[
                        const Divider(),
                        const SizedBox(height: AppSpacing.compact),
                        Row(
                          children: [
                            _StatItem(
                              value: user.rating.toStringAsFixed(1),
                              label: 'Note',
                              icon: Icons.star_rounded,
                              color: AppColors.primaryContainer,
                            ),
                            _Divider(),
                            _StatItem(
                              value: '${user.reviewCount}',
                              label: 'Avis',
                              icon: Icons.chat_bubble_rounded,
                              color: AppColors.tertiary,
                            ),
                            _Divider(),
                            _StatItem(
                              value: '${user.completedMissions}',
                              label: 'Missions',
                              icon: Icons.task_alt_rounded,
                              color: AppColors.success,
                            ),
                            _Divider(),
                            _StatItem(
                              value: '${user.trustScore.toInt()}',
                              label: 'Trust',
                              icon: Icons.verified_user_rounded,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],

                      // Certification badge
                      if (user.isCertified && user.certificationBadge != null) ...[
                        const SizedBox(height: AppSpacing.compact),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: AppRadius.radiusFull,
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.workspace_premium_rounded,
                                size: 16, color: AppColors.tertiary),
                            const SizedBox(width: 6),
                            Text(user.certificationBadge!,
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.tertiary, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ],

                      // Profile completion bar
                      const SizedBox(height: AppSpacing.compact),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(children: [
                        Text('Profil complété à',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                        const Spacer(),
                        Text('78%',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.primary, fontWeight: FontWeight.w700,
                                letterSpacing: 0)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: AppRadius.radiusFull,
                        child: LinearProgressIndicator(
                          value: 0.78,
                          backgroundColor: AppColors.outlineVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Menu sections ─────────────────────────────────────────
                if (isProvider) ...[
                  _MenuSection(
                    title: 'Activité',
                    items: [
                      _MenuItem(Icons.task_alt_rounded, 'Mes missions', AppColors.primary,
                          () => context.push(AppRoutes.missionsList)),
                      _MenuItem(Icons.bar_chart_rounded, 'Mes revenus', AppColors.success,
                          () => context.push(AppRoutes.earnings)),
                      _MenuItem(Icons.star_rounded, 'Mes avis', AppColors.primaryContainer,
                          () => context.push(AppRoutes.reviews)),
                      _MenuItem(Icons.verified_user_rounded, 'Trust Score', AppColors.tertiary,
                          () {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.compact),
                ],

                _MenuSection(
                  title: 'Compte',
                  items: [
                    _MenuItem(Icons.account_balance_wallet_rounded, 'Wallet & Paiements',
                        AppColors.primary, () => context.push(AppRoutes.wallet)),
                    _MenuItem(Icons.verified_rounded, 'Vérification d\'identité',
                        AppColors.tertiary, () => context.push(AppRoutes.idVerification)),
                    _MenuItem(Icons.school_rounded, 'Formations & Certifications',
                        AppColors.success, () {}),
                    if (!isProvider)
                      _MenuItem(Icons.favorite_rounded, 'Mes favoris',
                          AppColors.error, () => context.push(AppRoutes.favorites)),
                  ],
                ),
                const SizedBox(height: AppSpacing.compact),

                _MenuSection(
                  title: 'Paramètres',
                  items: [
                    _MenuItem(Icons.settings_rounded, 'Paramètres', AppColors.onSurfaceVariant,
                        () => context.push(AppRoutes.settings)),
                    _MenuItem(Icons.help_outline_rounded, 'Aide & Support',
                        AppColors.tertiary, () {}),
                    _MenuItem(Icons.privacy_tip_outlined, 'Confidentialité',
                        AppColors.onSurfaceVariant, () {}),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                  child: GestureDetector(
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadius.radiusFull,
                        border: Border.all(color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('Se déconnecter',
                            style: AppTypography.button.copyWith(color: AppColors.error)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.generous),
              ],
            ),
          ),
        ],
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.icon, required this.color});
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: AppTypography.overline.copyWith(
            color: AppColors.onSurfaceVariant, letterSpacing: 0.3, fontSize: 9)),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 40,
    color: AppColors.outlineVariant,
  );
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});
  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(title, style: AppTypography.labelCaps.copyWith(
                color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Icon(item.icon, size: 18, color: item.color),
                      ),
                      title: Text(item.label, style: AppTypography.bodyMedium),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.onSurfaceVariant, size: 20),
                      onTap: item.onTap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(i == 0 ? AppRadius.lg : 0),
                          topRight: Radius.circular(i == 0 ? AppRadius.lg : 0),
                          bottomLeft: Radius.circular(isLast ? AppRadius.lg : 0),
                          bottomRight: Radius.circular(isLast ? AppRadius.lg : 0),
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 60),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}
