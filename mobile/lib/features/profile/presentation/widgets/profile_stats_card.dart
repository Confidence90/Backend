import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';

class ProfileStatsCard extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfileStatsCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final avgRating       = (profile['avg_rating']        as num?)?.toDouble() ?? 0.0;
    final totalReviews    = profile['total_reviews']       as int? ?? 0;
    final completedMissions = profile['completed_missions'] as int? ?? 0;
    final responseRate    = profile['response_rate']       as int? ?? 0;
    final isVerified      = profile['is_verified']         == true;
    final isCertified     = profile['is_certified']        == true;
    final categories      = (profile['categories']         as List? ?? []).cast<Map<String, dynamic>>();
    final skills          = (profile['skills']             as List? ?? []).cast<Map<String, dynamic>>();
    final expLevel        = profile['experience_level']    as String? ?? 'beginner';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xl,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // ── Stats row ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _StatItem(
                  value: avgRating.toStringAsFixed(1),
                  label: 'Note moy.',
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFBBF24),
                ),
                _Divider(),
                _StatItem(
                  value: '$totalReviews',
                  label: 'Avis',
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: AppColors.info,
                ),
                _Divider(),
                _StatItem(
                  value: '$completedMissions',
                  label: 'Missions',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.success,
                ),
                _Divider(),
                _StatItem(
                  value: '$responseRate%',
                  label: 'Réponse',
                  icon: Icons.reply_rounded,
                  iconColor: AppColors.primary,
                ),
              ],
            ),
          ).animate().slideY(begin: 0.1).fade(),

          const Divider(height: 1),

          // ── Trust badges ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                if (isVerified)   _TrustBadge(label: 'Identité vérifiée',  icon: Icons.verified_user_outlined, color: AppColors.info),
                if (isCertified)  _TrustBadge(label: 'Certifié BaaraLink', icon: Icons.workspace_premium_rounded, color: AppColors.warning),
                _TrustBadge(
                  label: _expLabel(expLevel),
                  icon: Icons.military_tech_outlined,
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          if (categories.isNotEmpty) ...[
            const Divider(height: 1),

            // ── Categories ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spécialités', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: categories.map((c) => _CategoryChip(
                      name: c['name'] as String? ?? '',
                      icon: c['icon'] as String? ?? '🔧',
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],

          if (skills.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compétences', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: skills.take(8).map((s) => _SkillChip(
                      name: s['name'] as String? ?? '',
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _expLabel(String level) {
    switch (level) {
      case 'intermediate': return 'Intermédiaire';
      case 'experienced':  return 'Expérimenté';
      case 'expert':       return 'Expert';
      default:             return 'Débutant';
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color iconColor;
  const _StatItem({required this.value, required this.label, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 18,
          fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        Text(label, style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondary,
        )),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 48, color: AppColors.divider,
  );
}

class _TrustBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _TrustBadge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: AppRadius.full,
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: color,
        )),
      ],
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  final String name, icon;
  const _CategoryChip({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: AppRadius.full,
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Text('$icon $name', style: const TextStyle(
      fontFamily: 'Poppins', fontSize: 12,
      fontWeight: FontWeight.w500, color: AppColors.primaryDark,
    )),
  );
}

class _SkillChip extends StatelessWidget {
  final String name;
  const _SkillChip({required this.name});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: AppRadius.full,
      border: Border.all(color: AppColors.border),
    ),
    child: Text(name, style: const TextStyle(
      fontFamily: 'Poppins', fontSize: 11,
      fontWeight: FontWeight.w500, color: AppColors.textSecondary,
    )),
  );
}
