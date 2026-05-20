import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;
  final bool compact;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.compact = false,
  });

  Color _urgencyColor(String? urgency) {
    switch (urgency) {
      case 'high':   return AppColors.error;
      case 'medium': return AppColors.warning;
      default:       return AppColors.textTertiary;
    }
  }

  String _urgencyLabel(String? urgency) {
    switch (urgency) {
      case 'high':   return '🔴 Urgent';
      case 'medium': return '🟡 Sous 48h';
      default:       return '🟢 Flexible';
    }
  }

  String _jobTypeLabel(String? type) {
    switch (type) {
      case 'mission':    return 'Mission';
      case 'full_time':  return 'CDI';
      case 'part_time':  return 'Temps partiel';
      case 'contract':   return 'CDD';
      case 'freelance':  return 'Freelance';
      case 'internship': return 'Stage';
      default:           return 'Mission';
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgency        = job['urgency']       as String?;
    final status         = job['status']        as String?;
    final budgetMin      = job['budget_min']    as int?;
    final budgetMax      = job['budget_max']    as int?;
    final categoryName   = job['category_name'] as String? ?? 'Général';
    final categoryIcon   = job['category_icon'] as String?;
    final city           = job['city']          as String? ?? 'Bamako';
    final district       = job['district']      as String?;
    final clientName     = job['client_name']   as String? ?? '';
    final appCount       = job['applications_count'] as int? ?? 0;
    final title          = job['title']         as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top accent bar based on urgency ──
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: _urgencyColor(urgency),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Header row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon bubble
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: AppRadius.md,
                        ),
                        child: Center(
                          child: Text(
                            categoryIcon ?? '🔧',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Status badge
                      StatusBadge.jobStatus(status ?? 'open'),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Location + client ──
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        district != null ? '$district, $city' : city,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.person_outline, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          clientName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 14),

                  // ── Footer row ──
                  Row(
                    children: [
                      // Budget
                      if (budgetMin != null || budgetMax != null) ...[
                        const Icon(Icons.payments_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          _buildBudgetText(budgetMin, budgetMax),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Urgency badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _urgencyColor(urgency).withOpacity(0.1),
                          borderRadius: AppRadius.full,
                        ),
                        child: Text(
                          _urgencyLabel(urgency),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _urgencyColor(urgency),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Job type
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadius.full,
                        ),
                        child: Text(
                          _jobTypeLabel(job['job_type'] as String?),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (appCount > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.group_outlined, size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '$appCount candidature${appCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildBudgetText(int? min, int? max) {
    if (min != null && max != null) {
      return '${_fmt(min)} – ${_fmt(max)} FCFA';
    } else if (min != null) {
      return 'À partir de ${_fmt(min)} FCFA';
    } else if (max != null) {
      return 'Jusqu\'à ${_fmt(max)} FCFA';
    }
    return 'Budget à négocier';
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]} ',
  );
}
