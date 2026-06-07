import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';
import '../buttons/app_buttons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShimmerBox — base shimmer block
// ─────────────────────────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : AppColors.shimmerBase,
      highlightColor: isDark ? const Color(0xFF3A3A3A) : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ArtisanCardShimmer — skeleton for artisan list items
// ─────────────────────────────────────────────────────────────────────────────
class ArtisanCardShimmer extends StatelessWidget {
  const ArtisanCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          ShimmerBox(width: AppSpacing.avatarMd, height: AppSpacing.avatarMd, radius: 100),
          const SizedBox(width: AppSpacing.compact),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 16, radius: 6),
                const SizedBox(height: 8),
                ShimmerBox(width: 100, height: 12, radius: 6),
                const SizedBox(height: 8),
                ShimmerBox(width: 180, height: 12, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MissionCardShimmer
// ─────────────────────────────────────────────────────────────────────────────
class MissionCardShimmer extends StatelessWidget {
  const MissionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 80, height: 22, radius: 100),
              const Spacer(),
              ShimmerBox(width: 70, height: 16, radius: 6),
            ],
          ),
          const SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 16, radius: 6),
          const SizedBox(height: 8),
          ShimmerBox(width: 150, height: 13, radius: 6),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardShimmer — provider dashboard skeleton
// ─────────────────────────────────────────────────────────────────────────────
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile hero
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                ShimmerBox(width: 60, height: 60, radius: 100),
                const SizedBox(width: AppSpacing.compact),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 130, height: 18, radius: 6),
                      const SizedBox(height: 8),
                      ShimmerBox(width: 100, height: 13, radius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Revenue card
          ShimmerBox(width: double.infinity, height: 120, radius: 16),
          const SizedBox(height: 14),
          // Stats grid
          Row(
            children: [
              Expanded(child: ShimmerBox(width: null, height: 80, radius: 12)),
              const SizedBox(width: 10),
              Expanded(child: ShimmerBox(width: null, height: 80, radius: 12)),
              const SizedBox(width: 10),
              Expanded(child: ShimmerBox(width: null, height: 80, radius: 12)),
            ],
          ),
          const SizedBox(height: 20),
          ShimmerBox(width: 120, height: 18, radius: 6),
          const SizedBox(height: 12),
          MissionCardShimmer(),
          const SizedBox(height: 10),
          MissionCardShimmer(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EmptyStateWidget
// ─────────────────────────────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.h3.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ErrorStateWidget
// ─────────────────────────────────────────────────────────────────────────────
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.message = 'Une erreur est survenue',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: 'Problème de connexion',
      subtitle: message,
      actionLabel: onRetry != null ? 'Réessayer' : null,
      onAction: onRetry,
    );
  }
}
