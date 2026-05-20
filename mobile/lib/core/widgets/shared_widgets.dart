import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

// ─── App Button ──────────────────────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        height: height ?? 52,
        width: double.infinity,
        child: OutlinedButton(onPressed: isLoading ? null : onPressed, child: child),
      );
    }

    return SizedBox(
      height: height ?? 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: color != null
            ? ElevatedButton.styleFrom(backgroundColor: color)
            : null,
        child: child,
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  factory StatusBadge.urgency(String urgency) {
    switch (urgency) {
      case 'high':
        return StatusBadge(label: '🔴 Urgent', color: AppColors.error, backgroundColor: AppColors.errorSurface);
      case 'medium':
        return StatusBadge(label: '🟡 Sous 48h', color: AppColors.warning, backgroundColor: AppColors.warningSurface);
      default:
        return StatusBadge(label: '⚪ Normal', color: AppColors.textSecondary, backgroundColor: AppColors.surfaceVariant);
    }
  }

  factory StatusBadge.jobStatus(String status) {
    switch (status) {
      case 'open':
        return StatusBadge(label: 'Ouvert', color: AppColors.success, backgroundColor: AppColors.successSurface);
      case 'in_progress':
        return StatusBadge(label: 'En cours', color: AppColors.info, backgroundColor: AppColors.infoSurface);
      case 'completed':
        return StatusBadge(label: 'Terminé', color: AppColors.textSecondary, backgroundColor: AppColors.surfaceVariant);
      case 'cancelled':
        return StatusBadge(label: 'Annulé', color: AppColors.error, backgroundColor: AppColors.errorSurface);
      default:
        return StatusBadge(label: status, color: AppColors.textSecondary, backgroundColor: AppColors.surfaceVariant);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Rating Stars ─────────────────────────────────────────────────────────────
class RatingStars extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: const Color(0xFFFBBF24), size: size),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size - 1,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (totalReviews > 0) ...[
          const SizedBox(width: 3),
          Text(
            '($totalReviews)',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size - 2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Avatar Widget ────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool isOnline;
  final bool isVerified;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 48,
    this.isOnline = false,
    this.isVerified = false,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primarySurface,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: imageUrl != null
              ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _InitialsWidget(_initials, size),
                  ),
                )
              : _InitialsWidget(_initials, size),
        ),
        if (isOnline)
          Positioned(
            right: 0, bottom: 0,
            child: Container(
              width: size * 0.27,
              height: size * 0.27,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        if (isVerified)
          Positioned(
            right: 0, bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: const BoxDecoration(
                color: AppColors.info,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.verified, color: Colors.white, size: size * 0.2),
            ),
          ),
      ],
    );
  }
}

class _InitialsWidget extends StatelessWidget {
  final String initials;
  final double size;
  const _InitialsWidget(this.initials, this.size);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Skeleton Loader ─────────────────────────────────────────────────────────
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppRadius.md,
        ),
      ),
    );
  }
}

class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const SkeletonBox(width: 40, height: 40, borderRadius: AppRadius.md),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SkeletonBox(width: MediaQuery.of(context).size.width * 0.45, height: 14),
                const SizedBox(height: 6),
                SkeletonBox(width: MediaQuery.of(context).size.width * 0.3, height: 11),
              ]),
            ]),
            const SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 11),
            const SizedBox(height: 6),
            SkeletonBox(width: MediaQuery.of(context).size.width * 0.7, height: 11),
            const SizedBox(height: 12),
            Row(children: [
              const SkeletonBox(width: 60, height: 24),
              const SizedBox(width: 8),
              const SkeletonBox(width: 80, height: 24),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(label: buttonLabel!, onPressed: onAction, height: 48),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Network Error ────────────────────────────────────────────────────────────
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  const NetworkErrorWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '📡',
      title: 'Connexion interrompue',
      subtitle: 'Vérifiez votre connexion internet et réessayez.',
      buttonLabel: 'Réessayer',
      onAction: onRetry,
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

// ─── Divider with label ───────────────────────────────────────────────────────
class LabeledDivider extends StatelessWidget {
  final String label;
  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 12, color: AppColors.textTertiary,
        )),
      ),
      const Expanded(child: Divider()),
    ]);
  }
}
