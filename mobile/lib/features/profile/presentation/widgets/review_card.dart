import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final reviewerName   = review['reviewer_name']   as String? ?? 'Anonyme';
    final reviewerAvatar = review['reviewer_avatar'] as String?;
    final rating         = review['rating']          as int? ?? 5;
    final comment        = review['comment']         as String? ?? '';
    final createdAt      = review['created_at']      as String?;
    final response       = review['response']        as String?;
    final quality        = review['quality_rating']        as int?;
    final punctuality    = review['punctuality_rating']    as int?;
    final communication  = review['communication_rating']  as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: reviewerName, imageUrl: reviewerAvatar, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reviewerName, style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                    )),
                    Text(
                      _timeAgo(createdAt),
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 11, color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: const Color(0xFFFBBF24),
                )),
              ),
            ],
          ),

          // ── Comment ──
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(comment, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 14,
              color: AppColors.textSecondary, height: 1.6,
            )),
          ],

          // ── Sub-ratings ──
          if (quality != null || punctuality != null || communication != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                if (quality       != null) _SubRating(label: 'Qualité',        rating: quality),
                if (punctuality   != null) _SubRating(label: 'Ponctualité',    rating: punctuality),
                if (communication != null) _SubRating(label: 'Communication',  rating: communication),
              ],
            ),
          ],

          // ── Response ──
          if (response != null && response.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Réponse du prestataire', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                  )),
                  const SizedBox(height: 4),
                  Text(response, style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    color: AppColors.textPrimary, height: 1.5,
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return timeago.format(DateTime.parse(dateStr).toLocal(), locale: 'fr');
    } catch (_) {
      return '';
    }
  }
}

class _SubRating extends StatelessWidget {
  final String label;
  final int rating;
  const _SubRating({required this.label, required this.rating});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 10, color: AppColors.textTertiary,
        )),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 12, color: const Color(0xFFFBBF24),
          )),
        ),
      ],
    ),
  );
}
