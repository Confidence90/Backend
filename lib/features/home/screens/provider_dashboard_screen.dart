import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/layout/app_layout.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/navigation/app_routes.dart';

class ProviderDashboardScreen extends ConsumerStatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  ConsumerState<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends ConsumerState<ProviderDashboardScreen> {
  int _navIndex = 0;
  bool _isLoading = false;

  final _fcfa = NumberFormat('#,###', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentProvider;
    final wallet = MockData.providerWallet;
    final missions = MockData.activeMissions;

    return AppScaffold(
      topBar: BaaraLinkAppBar(
        userInitials: _initials(user.name),
        notificationCount: 3,
        onNotificationTap: () => context.push(AppRoutes.notifications),
        onAvatarTap: () => context.push(AppRoutes.profile),
      ),
      bottomNav: ProviderBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
      body: _isLoading
          ? const DashboardShimmer()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.only(
                  left: AppSpacing.marginMobile,
                  right: AppSpacing.marginMobile,
                  top: AppSpacing.md,
                  bottom: AppSpacing.generous,
                ),
                children: [
                  // ── Profile Hero Card ────────────────────────────────────
                  _ProfileHeroCard(user: user),
                  const SizedBox(height: AppSpacing.compact),

                  // ── Revenue / Wallet Card ────────────────────────────────
                  _RevenueCard(wallet: wallet, fcfa: _fcfa),
                  const SizedBox(height: AppSpacing.compact),

                  // ── Stats Grid ──────────────────────────────────────────
                  _StatsGrid(user: user),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Active Missions ─────────────────────────────────────
                  SectionHeader(
                    title: 'Missions actives',
                    actionLabel: 'Voir tout',
                    onAction: () => context.push(AppRoutes.missionsList),
                  ),
                  const SizedBox(height: AppSpacing.compact),

                  if (missions.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.task_alt_rounded,
                      title: 'Aucune mission active',
                      subtitle: 'Les nouvelles missions apparaîtront ici.',
                    )
                  else
                    ...missions.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _MissionCard(mission: m, fcfa: _fcfa),
                        )),
                ],
              ),
            ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isLoading = false);
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1: context.push(AppRoutes.missionsList);
      case 2: context.push(AppRoutes.chatList);
      case 3: context.push(AppRoutes.wallet);
      case 4: context.push(AppRoutes.profile);
    }
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Hero Card
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                initials: _initials(user.name),
                size: AppSpacing.avatarLg,
                showVerified: user.isVerified,
                borderColor: AppColors.outlineVariant,
              ),
              const SizedBox(width: AppSpacing.compact),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: AppTypography.bodyLarge
                                .copyWith(fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const VerifiedBadge(small: true),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.specialty ?? 'Prestataire'} • ${user.location ?? 'Bamako'}',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    StarRating(
                      rating: user.rating,
                      showValue: true,
                      showCount: true,
                      count: user.reviewCount,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.compact),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.compact),
          // Profile completion
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profil complété',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.onSurfaceVariant)),
              Text('78%',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
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
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Revenue / Wallet Card
// ─────────────────────────────────────────────────────────────────────────────
class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.wallet, required this.fcfa});
  final Wallet wallet;
  final NumberFormat fcfa;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.wallet),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFD06000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        'SOLDE WALLET',
                        style: AppTypography.overline
                            .copyWith(color: Colors.white, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white70, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenus ce mois',
                        style: AppTypography.bodySmall
                            .copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fcfa.format(wallet.monthlyEarnings)} FCFA',
                        style: AppTypography.amountHero
                            .copyWith(color: Colors.white, fontSize: 32),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '+${wallet.monthlyGrowthPercent.toStringAsFixed(0)}% vs mois dernier',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Escrow badge
                if (wallet.escrowBalance > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Column(
                      children: [
                        Text('EN ESCROW',
                            style: AppTypography.overline.copyWith(
                              color: Colors.white60,
                              fontSize: 9,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          '${fcfa.format(wallet.escrowBalance)}',
                          style: AppTypography.bodySmall.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text('FCFA',
                            style: AppTypography.overline
                                .copyWith(color: Colors.white60, fontSize: 8)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Grid
// ─────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.visibility_rounded,
            iconColor: AppColors.primary,
            value: '1 204',
            label: 'VUES PROFIL',
            bgColor: AppColors.surfaceContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.speed_rounded,
            iconColor: AppColors.tertiary,
            value: '98%',
            label: 'RÉPONSE',
            bgColor: AppColors.secondaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: Icons.task_alt_rounded,
            iconColor: AppColors.primaryContainer,
            value: user.completedMissions.toString(),
            label: 'MISSIONS',
            bgColor: AppColors.surfaceContainerHighest,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TrustScoreIndicator(score: user.trustScore),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 6),
          Text(value,
              style:
                  AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.overline.copyWith(
                fontSize: 9,
                letterSpacing: 0.6,
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission Card
// ─────────────────────────────────────────────────────────────────────────────
class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.fcfa});
  final Mission mission;
  final NumberFormat fcfa;

  @override
  Widget build(BuildContext context) {
    final statusBadge = switch (mission.status) {
      MissionStatusType.inProgress => (
          'EN COURS',
          AppColors.successContainer,
          AppColors.success
        ),
      MissionStatusType.inEscrow => ('DEMAIN', AppColors.secondaryContainer, AppColors.secondary),
      _ => ('EN ATTENTE', AppColors.warningContainer, AppColors.warning),
    };

    return GestureDetector(
      onTap: () => context.push('/mission/${mission.id}'),
      child: Container(
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBadge.$2,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: Text(statusBadge.$1,
                      style: AppTypography.overline
                          .copyWith(color: statusBadge.$3, letterSpacing: 0.8)),
                ),
                const Spacer(),
                Text(
                  '${fcfa.format(mission.budget)} FCFA',
                  style: AppTypography.amountMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(mission.title,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 3),
                Text(mission.location,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),

            // Action buttons for in-progress missions
            if (mission.status == MissionStatusType.inProgress) ...[
              const SizedBox(height: AppSpacing.compact),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.radiusFull,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.task_alt_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text('Terminer',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => context.push('/chat/conv-001'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: AppRadius.radiusFull,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_rounded,
                              size: 16, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('Chat',
                              style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
