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
import '../../../shared/providers/app_providers.dart';
import '../../../shared/navigation/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MissionsListScreen — tabbed list of all missions
// ─────────────────────────────────────────────────────────────────────────────
class MissionsListScreen extends ConsumerStatefulWidget {
  const MissionsListScreen({super.key});

  @override
  ConsumerState<MissionsListScreen> createState() => _MissionsListScreenState();
}

class _MissionsListScreenState extends ConsumerState<MissionsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _fcfa = NumberFormat('#,###', 'fr_FR');

  static const _tabs = [
    (MissionTab.active, 'En cours'),
    (MissionTab.upcoming, 'À venir'),
    (MissionTab.completed, 'Terminées'),
    (MissionTab.cancelled, 'Annulées'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(missionsProvider.notifier).setTab(_tabs[_tabController.index].$1);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionsProvider);

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
        title: Text('Mes Missions', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
            color: AppColors.onSurfaceVariant,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTypography.bodySmall,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
      body: state.isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: MissionCardShimmer(),
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(missionsProvider.notifier).refresh(),
              child: state.missions.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.task_alt_rounded,
                      title: 'Aucune mission ici',
                      subtitle: 'Vos missions apparaîtront ici.',
                      actionLabel: 'Voir les opportunités',
                      onAction: () => context.push(AppRoutes.search),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.marginMobile),
                      itemCount: state.missions.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _MissionListCard(
                          mission: state.missions[i],
                          fcfa: _fcfa,
                          onTap: () => context.push('/mission/${state.missions[i].id}'),
                        ),
                      ),
                    ),
            ),
    );
  }
}

class _MissionListCard extends StatelessWidget {
  const _MissionListCard({required this.mission, required this.fcfa, required this.onTap});
  final Mission mission;
  final NumberFormat fcfa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusBg, statusFg) = switch (mission.status) {
      MissionStatusType.inProgress => ('EN COURS', AppColors.successContainer, AppColors.success),
      MissionStatusType.inEscrow => ('EN ESCROW', AppColors.warningContainer, AppColors.warning),
      MissionStatusType.completed => ('TERMINÉE', AppColors.surfaceContainer, AppColors.onSurfaceVariant),
      MissionStatusType.cancelled => ('ANNULÉE', AppColors.errorContainer, AppColors.error),
      _ => ('EN ATTENTE', AppColors.secondaryContainer, AppColors.secondary),
    };

    return GestureDetector(
      onTap: onTap,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusBg, borderRadius: AppRadius.radiusFull),
                  child: Text(statusLabel, style: AppTypography.overline.copyWith(
                      color: statusFg, letterSpacing: 0.8)),
                ),
                const Spacer(),
                Text('${fcfa.format(mission.budget)} FCFA',
                    style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(mission.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 3),
                Text(mission.location, style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant)),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 3),
                Text(mission.scheduledAt?.substring(0, 10) ?? 'Non planifiée',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MissionDetailScreen — full mission progress + actions
// ─────────────────────────────────────────────────────────────────────────────
class MissionDetailScreen extends ConsumerStatefulWidget {
  const MissionDetailScreen({super.key, required this.missionId});
  final String missionId;

  @override
  ConsumerState<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends ConsumerState<MissionDetailScreen> {
  final _fcfa = NumberFormat('#,###', 'fr_FR');
  bool _completing = false;

  Mission get _mission => MockData.activeMissions.firstWhere(
        (m) => m.id == widget.missionId,
        orElse: () => MockData.activeMissions.first,
      );

  @override
  Widget build(BuildContext context) {
    final m = _mission;

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
        title: Text('Détail Mission', style: AppTypography.h3),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: AppRadius.radiusFull,
            ),
            child: Text('EN COURS', style: AppTypography.overline.copyWith(
                color: AppColors.success, letterSpacing: 0.8)),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Details card
            _DetailCard(mission: m, fcfa: _fcfa),
            const SizedBox(height: AppSpacing.compact),

            // Client info
            _ClientCard(mission: m),
            const SizedBox(height: AppSpacing.compact),

            // Timeline
            _TimelineCard(status: m.status),
            const SizedBox(height: AppSpacing.compact),

            // Payment breakdown
            _PaymentCard(mission: m, fcfa: _fcfa),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile, AppSpacing.compact, AppSpacing.marginMobile, AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PrimaryButton(
                  label: 'Marquer terminée',
                  onPressed: _complete,
                  isLoading: _completing,
                  icon: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () => context.push('/chat/conv-001'),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(100),
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

  Future<void> _complete() async {
    setState(() => _completing = true);
    await ref.read(missionsProvider.notifier).completeMission(widget.missionId);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _completing = false);
      _showRatingSheet();
    }
  }

  void _showRatingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RatingSheet(
        onSubmit: (rating, review) {
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.mission, required this.fcfa});
  final Mission mission;
  final NumberFormat fcfa;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mission.title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.compact),
          _InfoRow(Icons.category_rounded, mission.category, AppColors.primary),
          _InfoRow(Icons.location_on_rounded, mission.location, AppColors.tertiary),
          _InfoRow(Icons.calendar_today_rounded,
              mission.scheduledAt?.substring(0, 16).replaceAll('T', ' à ') ?? 'Non définie',
              AppColors.warning),
          if (mission.description != null) ...[
            const Divider(height: AppSpacing.lg),
            Text('Description', style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            Text(mission.description!, style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant, height: 1.6)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: AppTypography.bodySmall)),
    ]),
  );
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.mission});
  final Mission mission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          AppAvatar(initials: 'AC', size: 48, showVerified: true),
          const SizedBox(width: AppSpacing.compact),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aminata Coulibaly', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                Text('Client • ACI 2000', style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                StarRating(rating: 4.9, size: 12, showValue: true),
              ],
            ),
          ),
          Column(children: [
            GestureDetector(
              onTap: () => context.push('/chat/conv-001'),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: AppRadius.radiusFull,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.onSurfaceVariant),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.status});
  final MissionStatusType status;

  static const _steps = [
    (Icons.check_rounded, 'Mission acceptée', '08:45', true),
    (Icons.directions_car_rounded, 'En route', '10:15', true),
    (Icons.build_rounded, 'Intervention en cours', '10:30', false),
    (Icons.task_alt_rounded, 'Mission terminée', 'En attente', false),
  ];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progression', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            final isCompleted = step.$4;
            final isActive = i == 2;
            final isLast = i == _steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: AppAnimations.standard,
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primary
                            : isActive
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: isActive
                            ? null
                            : Border.all(color: isCompleted ? AppColors.primary : AppColors.outlineVariant),
                      ),
                      child: Icon(step.$1,
                          size: 14,
                          color: isCompleted || isActive ? Colors.white : AppColors.onSurfaceVariant),
                    ),
                    if (!isLast)
                      AnimatedContainer(
                        duration: AppAnimations.standard,
                        width: 2,
                        height: 32,
                        color: isCompleted ? AppColors.primary : AppColors.outlineVariant,
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.compact),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(step.$2,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                color: isActive ? AppColors.primary : AppColors.onSurface,
                              )),
                        ),
                        Text(step.$3,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.mission, required this.fcfa});
  final Mission mission;
  final NumberFormat fcfa;

  @override
  Widget build(BuildContext context) {
    final commission = (mission.budget * 0.075).round();
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
          Text('Paiement', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.compact),
          _PayRow('Montant mission', '${fcfa.format(mission.budget)} FCFA'),
          _PayRow('Commission BaaraLink (7.5%)', '−${fcfa.format(commission)} FCFA'),
          const Divider(height: AppSpacing.md),
          Row(
            children: [
              Text('Vous recevrez', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${fcfa.format(mission.budget - commission)} FCFA',
                  style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.success, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: AppRadius.radiusFull,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text('En escrow — libéré après validation',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.warning, letterSpacing: 0, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _PayRow extends StatelessWidget {
  const _PayRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant))),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _RatingSheet extends StatefulWidget {
  const _RatingSheet({required this.onSubmit});
  final void Function(double rating, String review) onSubmit;

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  double _rating = 5.0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 32, height: 4,
              decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: AppRadius.radiusFull),
            )),
            const SizedBox(height: AppSpacing.lg),
            Text('Comment s\'est passé ?', style: AppTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            // Star selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 40,
                    color: AppColors.primaryContainer,
                  ),
                ),
              )),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Laisse un avis (optionnel)…',
                labelText: 'Commentaire',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Envoyer l\'avis',
              onPressed: () => widget.onSubmit(_rating, _reviewController.text),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ActiveMissionsScreen — provider active missions view
// ─────────────────────────────────────────────────────────────────────────────
class ActiveMissionsScreen extends ConsumerWidget {
  const ActiveMissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionsProvider);
    final active = state.missions.where((m) => m.status == MissionStatusType.inProgress).toList();
    final fcfa = NumberFormat('#,###', 'fr_FR');

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
        title: Text('Missions en cours', style: AppTypography.h3),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: active.isEmpty
          ? EmptyStateWidget(
              icon: Icons.task_alt_rounded,
              title: 'Aucune mission active',
              subtitle: 'Acceptez une mission pour la voir apparaître ici.',
              actionLabel: 'Voir les opportunités',
              onAction: () => context.push(AppRoutes.search),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.read(missionsProvider.notifier).refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                itemCount: active.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ActiveMissionCard(mission: active[i], fcfa: fcfa),
                ),
              ),
            ),
    );
  }
}

class _ActiveMissionCard extends StatelessWidget {
  const _ActiveMissionCard({required this.mission, required this.fcfa});
  final Mission mission;
  final NumberFormat fcfa;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.4), blurRadius: 6)]),
            ),
            const SizedBox(width: 6),
            Text('EN COURS', style: AppTypography.overline.copyWith(
                color: AppColors.success, letterSpacing: 0.8)),
            const Spacer(),
            Text('${fcfa.format(mission.budget)} FCFA',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(mission.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 13, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 3),
            Text(mission.location, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          ]),
          const SizedBox(height: AppSpacing.compact),
          Row(children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => context.push('/mission/${mission.id}'),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.radiusFull,
                  ),
                  child: Center(child: Text('Voir détails',
                      style: AppTypography.bodySmall.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/chat/conv-001'),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: AppRadius.radiusFull,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    size: 16, color: AppColors.onSurfaceVariant),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
