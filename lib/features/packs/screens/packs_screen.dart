import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../core/constants/app_constants.dart';

class PacksScreen extends StatefulWidget {
  const PacksScreen({super.key});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  String _selectedPack = 'premium';

  @override
  Widget build(BuildContext context) {
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
        title: Text('Packs Client Premium', style: AppTypography.h3),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero explanation
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.06), AppColors.primary.withOpacity(0.02)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text('Comment ça marche ?',
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: AppSpacing.compact),
                  ...[
                    (Icons.search_rounded, '1. Vous nous dites ce dont vous avez besoin'),
                    (Icons.verified_user_rounded, '2. On sélectionne les meilleurs prestataires vérifiés'),
                    (Icons.notifications_active_rounded, '3. Ils vous contactent directement'),
                    (Icons.payments_rounded, '4. Vous payez en Mobile Money après le service'),
                  ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(item.$1, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.$2,
                          style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant, height: 1.4))),
                    ]),
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Choisissez votre pack', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.compact),

            // Pack Basic
            _PackCard(
              id: 'basic',
              name: 'Pack Basic',
              price: AppConstants.packBasicPrice,
              profiles: AppConstants.packBasicProfiles,
              description: 'Recevez une sélection de ${AppConstants.packBasicProfiles} prestataires qualifiés selon vos critères.',
              features: [
                (true, '${AppConstants.packBasicProfiles} profils sélectionnés par BaaraLink'),
                (true, 'Tri par note, proximité et tarif'),
                (true, 'Profils vérifiés uniquement'),
                (true, 'Contact direct dans les 2h'),
                (false, 'Gestion de l\'intervention'),
                (false, 'Support prioritaire 7j/7'),
              ],
              isRecommended: false,
              isSelected: _selectedPack == 'basic',
              onSelect: () => setState(() => _selectedPack = 'basic'),
            ),
            const SizedBox(height: AppSpacing.compact),

            // Pack Premium
            _PackCard(
              id: 'premium',
              name: 'Pack Premium',
              price: AppConstants.packPremiumPrice,
              profiles: AppConstants.packPremiumProfiles,
              description: 'Service complet : sélection, organisation et suivi de votre intervention.',
              features: [
                (true, '${AppConstants.packPremiumProfiles} profils sélectionnés par BaaraLink'),
                (true, 'Tri par note, proximité et tarif'),
                (true, 'Profils vérifiés uniquement'),
                (true, 'Contact direct dans les 1h'),
                (true, 'Intervention organisée par BaaraLink'),
                (true, 'Support prioritaire 7j/7'),
              ],
              isRecommended: true,
              isSelected: _selectedPack == 'premium',
              onSelect: () => setState(() => _selectedPack = 'premium'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Guarantee strip
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Row(children: [
                const Icon(Icons.security_rounded, color: AppColors.success, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Satisfait ou remboursé. Si aucun prestataire ne convient, nous remboursons intégralement.',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Activer le Pack ${_selectedPack == 'basic' ? 'Basic — ${AppConstants.packBasicPrice} FCFA' : 'Premium — ${AppConstants.packPremiumPrice} FCFA'}',
              onPressed: () => context.push(
                '${AppRoutes.payment}?amount=${_selectedPack == 'basic' ? AppConstants.packBasicPrice : AppConstants.packPremiumPrice}&title=Pack+${_selectedPack == 'basic' ? 'Basic' : 'Premium'}+BaaraLink',
              ),
              icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(height: AppSpacing.generous),
          ],
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.id, required this.name, required this.price,
    required this.profiles, required this.description, required this.features,
    required this.isRecommended, required this.isSelected, required this.onSelect,
  });

  final String id;
  final String name;
  final int price;
  final int profiles;
  final String description;
  final List<(bool, String)> features;
  final bool isRecommended;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surfaceContainer,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.workspace_premium_rounded,
                          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.compact),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                          Row(children: [
                            Text('${_fcfa(price)} FCFA',
                                style: AppTypography.amountMedium.copyWith(
                                    color: AppColors.primary, fontSize: 20)),
                            Text(' / intervention',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                          ]),
                        ]),
                      ),
                      AnimatedContainer(
                        duration: AppAnimations.fast,
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(description,
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant, height: 1.5)),
                  const SizedBox(height: AppSpacing.compact),
                  const Divider(),
                  const SizedBox(height: AppSpacing.compact),
                  ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(
                        f.$1 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 18,
                        color: f.$1 ? AppColors.success : AppColors.outlineVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f.$2,
                            style: AppTypography.bodySmall.copyWith(
                                color: f.$1 ? AppColors.onSurface : AppColors.onSurfaceVariant)),
                      ),
                    ]),
                  )),
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text('Recommandé',
                      style: AppTypography.overline.copyWith(
                          color: Colors.white, letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fcfa(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final chars = s.split('').reversed.toList();
    final result = <String>[];
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) result.add(' ');
      result.add(chars[i]);
    }
    return result.reversed.join('');
  }
}
