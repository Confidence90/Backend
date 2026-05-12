import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  final bool isOwnProfile;
  final VoidCallback? onEditTap;
  final VoidCallback? onContactTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.isOwnProfile = false,
    this.onEditTap,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final name         = profile['user_name']  as String? ?? '';
    final avatar       = profile['avatar']     as String?;
    final city         = profile['city']       as String? ?? 'Bamako';
    final district     = profile['district']   as String?;
    final bio          = profile['bio']        as String? ?? '';
    final isVerified   = profile['is_verified']  == true;
    final isCertified  = profile['is_certified'] == true;
    final badge        = profile['badge']      as String?;
    final availability = profile['availability'] as String? ?? 'available';
    final completion   = (profile['completion_score'] as int? ?? 0);
    final hourlyRate   = profile['hourly_rate'] as int?;

    return Container(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Column(
        children: [
          // ── Gradient banner ──
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B00), Color(0xFFFF8C3A)],
                  ),
                ),
                child: Opacity(
                  opacity: 0.15,
                  child: CustomPaint(painter: _PatternPainter()),
                ),
              ),

              // Avatar positioned at bottom of banner
              Positioned(
                bottom: -44,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 4),
                        boxShadow: AppShadows.elevated,
                      ),
                      child: UserAvatar(
                        name: name,
                        imageUrl: avatar,
                        size: 88,
                        isVerified: isVerified,
                      ),
                    ),
                    // Availability dot
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _availabilityColor(availability),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 52),

          // ── Info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                // Name + badges row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Color(0xFF3B82F6), size: 20),
                    ],
                    if (isCertified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.workspace_premium_rounded, color: AppColors.warning, size: 20),
                    ],
                  ],
                ).animate().fade(duration: 300.ms),

                const SizedBox(height: 4),

                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      district != null ? '$district, $city' : city,
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondary,
                      ),
                    ),
                    if (hourlyRate != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.payments_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        '$hourlyRate FCFA/h',
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13,
                          fontWeight: FontWeight.w600, color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ).animate(delay: 80.ms).fade(),

                const SizedBox(height: 10),

                // Availability chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _availabilityColor(availability).withOpacity(0.12),
                    borderRadius: AppRadius.full,
                    border: Border.all(
                      color: _availabilityColor(availability).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          color: _availabilityColor(availability),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _availabilityLabel(availability),
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _availabilityColor(availability),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bio
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    bio,
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                      color: AppColors.textSecondary, height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ).animate(delay: 120.ms).fade(),
                ],

                const SizedBox(height: 16),

                // Action buttons
                isOwnProfile
                    ? OutlinedButton.icon(
                        onPressed: onEditTap,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Modifier le profil'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onContactTap,
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                              label: const Text('Contacter'),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: AppRadius.lg,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                // Completion bar (own profile only)
                if (isOwnProfile && completion < 100) ...[
                  const SizedBox(height: 16),
                  _CompletionBar(score: completion),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _availabilityColor(String status) {
    switch (status) {
      case 'available':   return AppColors.success;
      case 'busy':        return AppColors.warning;
      default:            return AppColors.textTertiary;
    }
  }

  String _availabilityLabel(String status) {
    switch (status) {
      case 'available':   return 'Disponible';
      case 'busy':        return 'Occupé';
      default:            return 'Indisponible';
    }
  }
}

class _CompletionBar extends StatelessWidget {
  final int score;
  const _CompletionBar({required this.score});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: AppRadius.lg,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Complétion du profil', style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              fontWeight: FontWeight.w600, color: AppColors.primaryDark,
            )),
            Text('$score%', style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              fontWeight: FontWeight.w700, color: AppColors.primary,
            )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppRadius.full,
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 6,
            backgroundColor: AppColors.primaryLight.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Complétez votre profil pour plus de visibilité.', style: TextStyle(
          fontFamily: 'Poppins', fontSize: 11, color: AppColors.primaryDark,
        )),
      ],
    ),
  );
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 1..style = PaintingStyle.stroke;
    for (int i = 0; i < 10; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        30.0 * (i + 1),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
