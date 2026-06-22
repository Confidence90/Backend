import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/navigation/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WalletScreen
// ─────────────────────────────────────────────────────────────────────────────
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _fcfa = NumberFormat('#,###', 'fr_FR');
  bool _balanceVisible = true;

  late final _txGroups = [
    (
      'Aujourd\'hui',
      [
        MockData.recentTransactions[0],
        const Transaction(
          id: 'tx-004',
          title: 'Paiement Escrow',
          type: TransactionType.escrow,
          amount: 43000,
          description: 'Paiement en escrow',
          counterpartyName: 'Seydou K.',
          createdAt: '2025-05-14T10:00:00Z',
        ),
      ]
    ),
    (
      'Hier',
      [MockData.recentTransactions[1]],
    ),
    (
      '14 mai',
      [MockData.recentTransactions[2]],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wallet = MockData.providerWallet;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero wallet card ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: const Text('Mon Wallet'),
            titleTextStyle: AppTypography.h3.copyWith(color: Colors.white),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.marginMobile, 64, AppSpacing.marginMobile, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Solde disponible',
                                style: AppTypography.caption.copyWith(
                                    color: Colors.white70, letterSpacing: 0.5)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                              child: Icon(
                                _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.white60,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: AppAnimations.fast,
                          child: Text(
                            key: ValueKey(_balanceVisible),
                            _balanceVisible
                                ? '${_fcfa.format(wallet.balance)} FCFA'
                                : '••••••',
                            style: AppTypography.amountHero.copyWith(color: Colors.white),
                          ),
                        ),
                        if (_balanceVisible) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text('+${wallet.monthlyGrowthPercent.toStringAsFixed(0)}% ce mois',
                                  style: AppTypography.bodySmall
                                      .copyWith(color: Colors.white.withOpacity(0.9))),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        // Quick actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _WalletAction(icon: Icons.arrow_upward_rounded, label: 'Retirer',
                                onTap: () => context.push(AppRoutes.payment)),
                            _WalletAction(icon: Icons.arrow_downward_rounded, label: 'Recharger',
                                onTap: () => context.push(AppRoutes.payment)),
                            _WalletAction(icon: Icons.swap_horiz_rounded, label: 'Transférer', onTap: () {}),
                            _WalletAction(icon: Icons.receipt_long_rounded, label: 'Reçu', onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Stats summary row ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Row(children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Ce mois',
                    value: '${_fcfa.format(wallet.monthlyEarnings)} FCFA',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                    bgColor: AppColors.successContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'En escrow',
                    value: '${_fcfa.format(wallet.escrowBalance)} FCFA',
                    icon: Icons.lock_rounded,
                    color: AppColors.warning,
                    bgColor: AppColors.warningContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    label: 'Total gagné',
                    value: '${_fcfa.format(wallet.totalEarned)} FCFA',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                    bgColor: AppColors.surfaceContainer,
                  ),
                ),
              ]),
            ),
          ),

          // ── Transactions header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile, 0, AppSpacing.marginMobile, AppSpacing.sm),
              child: SectionHeader(
                title: 'Transactions',
                actionLabel: 'Tout voir',
                onAction: () {},
              ),
            ),
          ),

          // ── Transaction groups ─────────────────────────────────────────
          for (final group in _txGroups) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile, AppSpacing.sm, AppSpacing.marginMobile, 6),
                child: Text(group.$1,
                    style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
              ),
            ),
            SliverList.separated(
              itemCount: group.$2.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72, endIndent: AppSpacing.marginMobile),
              itemBuilder: (_, i) => _TransactionTile(
                transaction: group.$2[i],
                fcfa: _fcfa,
                isFirst: i == 0,
                isLast: i == group.$2.length - 1,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.generous)),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: Colors.white, letterSpacing: 0)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label, required this.value,
    required this.icon, required this.color, required this.bgColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.compact),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: AppTypography.caption
                  .copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w700, letterSpacing: 0),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label,
              style: AppTypography.overline
                  .copyWith(color: AppColors.onSurfaceVariant, fontSize: 9, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction, required this.fcfa,
    required this.isFirst, required this.isLast,
  });
  final Transaction transaction;
  final NumberFormat fcfa;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final isEscrow = transaction.type == TransactionType.escrow;

    final (iconData, iconColor, iconBg) = switch (transaction.type) {
      TransactionType.credit => (Icons.arrow_downward_rounded, AppColors.success, AppColors.successContainer),
      TransactionType.debit => (Icons.arrow_upward_rounded, AppColors.error, AppColors.errorContainer),
      TransactionType.escrow => (Icons.lock_rounded, AppColors.warning, AppColors.warningContainer),
      TransactionType.refund => (Icons.replay_rounded, AppColors.tertiary, AppColors.secondaryContainer),
    };

    final amountColor = isCredit
        ? AppColors.success
        : isEscrow
            ? AppColors.warning
            : AppColors.error;
    final amountPrefix = isCredit ? '+' : '−';

    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile, vertical: AppSpacing.compact),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, borderRadius: AppRadius.radiusMd),
            child: Icon(iconData, size: 22, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.compact),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description,
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (transaction.counterpartyName != null) ...[
                      Text(transaction.counterpartyName!,
                          style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant, letterSpacing: 0)),
                      Text(' • ', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                    Text(_formatDate(transaction.createdAt),
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
              Text(
                '$amountPrefix${fcfa.format(transaction.amount)} FCFA',
                style: AppTypography.bodySmall.copyWith(
                    color: amountColor, fontWeight: FontWeight.w700),
              ),
              if (isEscrow)
                Text('En attente', style: AppTypography.caption.copyWith(
                    color: AppColors.warning, letterSpacing: 0, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour}h${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
