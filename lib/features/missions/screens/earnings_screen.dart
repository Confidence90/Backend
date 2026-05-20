import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fcfa = NumberFormat('#,###', 'fr_FR');
    final wallet = MockData.providerWallet;

    final _weeklyData = [85000, 120000, 65000, 180000, 95000, 210000, 140000];
    final _labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final maxVal = _weeklyData.reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            expandedHeight: 220,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: const _WhiteText('Mes Revenus'),
            titleTextStyle: AppTypography.h3.copyWith(color: Colors.white),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total ce mois',
                            style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(
                          '${fcfa.format(wallet.monthlyEarnings)} FCFA',
                          style: AppTypography.amountHero.copyWith(color: Colors.white, fontSize: 34),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('+${wallet.monthlyGrowthPercent.toStringAsFixed(0)}% vs mois dernier',
                              style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9))),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Period selector ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Period tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: ['Semaine', 'Mois', 'Année'].map((p) {
                        final isSelected = p == 'Semaine';
                        return Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(p,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Bar chart placeholder
                  SectionHeader(title: 'Revenus cette semaine'),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(_weeklyData.length, (i) {
                              final h = (_weeklyData[i] / maxVal) * 100;
                              final isToday = i == 5;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isToday)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            '${fcfa.format(_weeklyData[i])}',
                                            style: AppTypography.overline.copyWith(
                                                color: AppColors.primary, fontSize: 8, letterSpacing: 0),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 800),
                                        height: h,
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? AppColors.primaryContainer
                                              : AppColors.surfaceContainer,
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6)),
                                          border: isToday
                                              ? Border.all(color: AppColors.primary.withOpacity(0.3))
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: _labels.map((l) => Expanded(
                            child: Text(l,
                                textAlign: TextAlign.center,
                                style: AppTypography.overline.copyWith(
                                    color: AppColors.onSurfaceVariant, fontSize: 10, letterSpacing: 0)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats grid
                  SectionHeader(title: 'Synthèse'),
                  const SizedBox(height: AppSpacing.compact),
                  Row(children: [
                    Expanded(child: _EarningStatCard(
                      icon: Icons.task_alt_rounded, iconColor: AppColors.success,
                      label: 'Missions terminées', value: '47', unit: 'ce mois',
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _EarningStatCard(
                      icon: Icons.access_time_rounded, iconColor: AppColors.tertiary,
                      label: 'Heures travaillées', value: '94h', unit: 'ce mois',
                    )),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _EarningStatCard(
                      icon: Icons.percent_rounded, iconColor: AppColors.warning,
                      label: 'Commission prélevée', value: '33 750', unit: 'FCFA',
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _EarningStatCard(
                      icon: Icons.account_balance_wallet_rounded, iconColor: AppColors.primary,
                      label: 'Net perçu', value: '416 250', unit: 'FCFA',
                    )),
                  ]),
                  const SizedBox(height: AppSpacing.lg),

                  // Category breakdown
                  SectionHeader(title: 'Par catégorie'),
                  const SizedBox(height: AppSpacing.compact),
                  ...[
                    ('Plomberie', 0.72, 324000),
                    ('Chauffe-eau', 0.18, 81000),
                    ('Installation', 0.10, 45000),
                  ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CategoryBreakdown(
                      label: item.$1, fraction: item.$2,
                      amount: fcfa.format(item.$3),
                    ),
                  )),

                  const SizedBox(height: AppSpacing.generous),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteText extends StatelessWidget {
  const _WhiteText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text);
}

class _EarningStatCard extends StatelessWidget {
  const _EarningStatCard({
    required this.icon, required this.iconColor, required this.label,
    required this.value, required this.unit,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.compact),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.amountMedium.copyWith(fontSize: 18)),
          Text(unit, style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant, letterSpacing: 0)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.overline.copyWith(
              color: AppColors.onSurfaceVariant, fontSize: 9, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.label, required this.fraction, required this.amount});
  final String label;
  final double fraction;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600))),
            Text('$amount FCFA', style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Text('${(fraction * 100).toInt()}%', style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant, letterSpacing: 0)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppRadius.radiusFull,
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: AppColors.outlineVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
