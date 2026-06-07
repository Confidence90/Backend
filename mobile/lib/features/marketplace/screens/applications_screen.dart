import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/layout/app_shared_widgets.dart';
import '../../../core/widgets/states/ux_states.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/navigation/app_routes.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final missions = MockData.activeMissions;

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
        title: Text('Mes Candidatures', style: AppTypography.h3),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: missions.isEmpty
          ? EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: 'Aucune candidature',
              subtitle: 'Les missions auxquelles vous avez postulé apparaîtront ici.',
              actionLabel: 'Chercher des missions',
              onAction: () => context.push(AppRoutes.search),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: missions.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ApplicationCard(mission: missions[i]),
              ),
            ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.mission});
  final Mission mission;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.missionPath(mission.id)),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(Icons.plumbing_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.compact),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mission.title, style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 13,
                        color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(mission.location, style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant)),
                  ]),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Text('En attente de réponse',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.secondary, letterSpacing: 0)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('${mission.budget} FCFA',
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
