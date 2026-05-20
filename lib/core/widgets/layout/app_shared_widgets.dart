import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VerifiedBadge
// ─────────────────────────────────────────────────────────────────────────────
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: Colors.white, size: small ? 10 : 12),
          const SizedBox(width: 3),
          Text(
            'Vérifié',
            style: AppTypography.overline.copyWith(
              color: Colors.white,
              fontSize: small ? 9 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PremiumBadge
// ─────────────────────────────────────────────────────────────────────────────
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, this.label = 'Top', this.small = false});
  final String label;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 1 : 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.radiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.overline.copyWith(
          color: AppColors.onPrimaryContainer,
          fontSize: small ? 9 : 10,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StatusBadge
// ─────────────────────────────────────────────────────────────────────────────
enum MissionStatus { active, upcoming, pending, completed, cancelled }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final MissionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      MissionStatus.active => ('EN COURS', AppColors.successContainer, AppColors.success),
      MissionStatus.upcoming => ('À VENIR', AppColors.secondaryContainer, AppColors.secondary),
      MissionStatus.pending => ('EN ATTENTE', AppColors.warningContainer, AppColors.warning),
      MissionStatus.completed => ('TERMINÉE', AppColors.surfaceContainerHighest, AppColors.onSurfaceVariant),
      MissionStatus.cancelled => ('ANNULÉE', AppColors.errorContainer, AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.radiusFull),
      child: Text(label, style: AppTypography.overline.copyWith(color: fg, letterSpacing: 0.8)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StarRating
// ─────────────────────────────────────────────────────────────────────────────
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 14,
    this.showValue = true,
    this.showCount = false,
    this.count,
  });

  final double rating;
  final double size;
  final bool showValue;
  final bool showCount;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half = !filled && i < rating;
          return Icon(
            filled
                ? Icons.star_rounded
                : half
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            color: AppColors.primaryContainer,
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: size * 0.9,
            ),
          ),
        ],
        if (showCount && count != null) ...[
          const SizedBox(width: 3),
          Text(
            '($count)',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: size * 0.85,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppAvatar
// ─────────────────────────────────────────────────────────────────────────────
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = AppSpacing.avatarMd,
    this.backgroundColor,
    this.foregroundColor,
    this.showVerified = false,
    this.showOnline = false,
    this.borderColor,
  });

  final String initials;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showVerified;
  final bool showOnline;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? AppColors.surfaceContainer;
    final fg = foregroundColor ?? AppColors.primary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 2)
                : null,
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl == null
              ? Center(
                  child: Text(
                    initials.toUpperCase(),
                    style: AppTypography.button.copyWith(
                      color: fg,
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
        ),
        if (showVerified)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: Icon(Icons.verified_rounded, color: Colors.white, size: size * 0.2),
            ),
          ),
        if (showOnline && !showVerified)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SectionHeader
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTypography.h3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            )),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterChip
// ─────────────────────────────────────────────────────────────────────────────
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.radiusFull,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TrustScoreIndicator
// ─────────────────────────────────────────────────────────────────────────────
class TrustScoreIndicator extends StatelessWidget {
  const TrustScoreIndicator({super.key, required this.score, this.size = 48});
  final double score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = score >= 85
        ? AppColors.success
        : score >= 70
            ? AppColors.primary
            : AppColors.warning;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 4,
                backgroundColor: AppColors.outlineVariant,
                color: color,
                strokeCap: StrokeCap.round,
              ),
              Text(
                '${score.toInt()}',
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Trust',
          style: AppTypography.overline.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// AppAnimations is defined in core/theme/app_animations.dart
