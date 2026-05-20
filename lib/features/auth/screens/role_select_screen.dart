import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/app_models.dart';

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen>
    with SingleTickerProviderStateMixin {
  UserRole? _selected;
  late AnimationController _entryController;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnims = [
      Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
      ),
      Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.15, 0.75, curve: Curves.easeOut)),
      ),
    ];

    _fadeAnims = [
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
      ),
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.15, 0.65, curve: Curves.easeIn)),
      ),
    ];

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    await ref.read(authProvider.notifier).selectRole(_selected!);
    if (!mounted) return;
    context.go(
      _selected == UserRole.provider
          ? AppRoutes.providerDashboard
          : AppRoutes.clientDashboard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider) is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Header
              Text(
                'Comment vas-tu\nutiliser BaaraLink ?',
                style: AppTypography.h1.copyWith(height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu pourras changer à tout moment dans tes paramètres.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Role cards
              AnimatedBuilder(
                animation: _entryController,
                builder: (_, __) => Column(
                  children: [
                    // Provider card
                    SlideTransition(
                      position: _slideAnims[0],
                      child: FadeTransition(
                        opacity: _fadeAnims[0],
                        child: _RoleCard(
                          role: UserRole.provider,
                          icon: Icons.handyman_rounded,
                          title: 'Je suis Prestataire',
                          subtitle:
                              'Artisan, électricien, ménagère, plombier… Propose tes services et gagne de l\'argent.',
                          features: const [
                            (Icons.task_alt_rounded, 'Missions & revenus'),
                            (Icons.star_rounded, 'Avis & Trust Score'),
                            (Icons.account_balance_wallet_rounded, 'Wallet Mobile Money'),
                          ],
                          primaryColor: AppColors.primary,
                          containerColor: AppColors.surfaceContainer,
                          selected: _selected == UserRole.provider,
                          onTap: () => setState(() => _selected = UserRole.provider),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.compact),

                    // Client card
                    SlideTransition(
                      position: _slideAnims[1],
                      child: FadeTransition(
                        opacity: _fadeAnims[1],
                        child: _RoleCard(
                          role: UserRole.client,
                          icon: Icons.person_search_rounded,
                          title: 'Je cherche un prestataire',
                          subtitle:
                              'Particulier, PME ou ONG. Trouve et réserve un prestataire vérifié en quelques minutes.',
                          features: const [
                            (Icons.search_rounded, 'Recherche intelligente'),
                            (Icons.workspace_premium_rounded, 'Pack Premium'),
                            (Icons.payments_rounded, 'Paiement sécurisé'),
                          ],
                          primaryColor: AppColors.tertiary,
                          containerColor: AppColors.secondaryContainer,
                          selected: _selected == UserRole.client,
                          onTap: () => setState(() => _selected = UserRole.client),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CTA
              AnimatedOpacity(
                duration: AppAnimations.fast,
                opacity: _selected != null ? 1.0 : 0.4,
                child: PrimaryButton(
                  label: 'Continuer',
                  onPressed: _selected != null ? _confirm : null,
                  isLoading: isLoading,
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoleCard
// ─────────────────────────────────────────────────────────────────────────────
class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.primaryColor,
    required this.containerColor,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<(IconData, String)> features;
  final Color primaryColor;
  final Color containerColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: _pressController.reverse,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.primaryColor.withOpacity(0.04)
                : AppColors.surfaceContainerLowest,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: widget.selected ? widget.primaryColor : AppColors.outlineVariant,
              width: widget.selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box
              AnimatedContainer(
                duration: AppAnimations.fast,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? widget.primaryColor.withOpacity(0.12)
                      : widget.containerColor,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(widget.icon, size: 28, color: widget.primaryColor),
              ),
              const SizedBox(width: AppSpacing.compact),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.compact),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.features
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: AppRadius.radiusFull,
                                  border: Border.all(color: AppColors.outlineVariant),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(f.$1, size: 12, color: widget.primaryColor),
                                    const SizedBox(width: 4),
                                    Text(f.$2,
                                        style: AppTypography.caption.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              AnimatedContainer(
                duration: AppAnimations.fast,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.selected ? widget.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: widget.selected ? widget.primaryColor : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: widget.selected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
