import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/widgets/buttons/app_buttons.dart';
import '../../../shared/navigation/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding data
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.backgroundIcon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.accentColor,
    required this.tags,
  });

  final IconData icon;
  final IconData backgroundIcon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color accentColor;
  final List<String> tags;
}

const _pages = [
  _OnboardingPage(
    icon: Icons.search_rounded,
    backgroundIcon: Icons.location_on_rounded,
    title: 'Trouve un artisan\nen 2 minutes',
    subtitle:
        'Plombier, électricien, ménagère… Des milliers de prestataires vérifiés près de chez toi à Bamako.',
    primaryColor: AppColors.primary,
    accentColor: AppColors.primaryContainer,
    tags: ['📍 Géolocalisation', '⚡ Réponse rapide', '✅ Vérifiés'],
  ),
  _OnboardingPage(
    icon: Icons.verified_user_rounded,
    backgroundIcon: Icons.star_rounded,
    title: 'Des profils\n100% vérifiés',
    subtitle:
        'Chaque prestataire est identifié et noté par de vrais clients. Fini les arnaques.',
    primaryColor: AppColors.tertiary,
    accentColor: AppColors.tertiaryContainer,
    tags: ['🔒 Identité vérifiée', '⭐ Avis authentiques', '🏅 Badges certifiés'],
  ),
  _OnboardingPage(
    icon: Icons.account_balance_wallet_rounded,
    backgroundIcon: Icons.payments_rounded,
    title: 'Paiement sécurisé\nOrange Money & Wave',
    subtitle:
        'Paie facilement en Mobile Money. L\'argent est libéré uniquement après validation du service.',
    primaryColor: AppColors.success,
    accentColor: Color(0xFF2ECC71),
    tags: ['🔐 Paiement escrow', '📱 Mobile Money', '🌊 Orange & Wave'],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingScreen
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: AppAnimations.standard);
    _entryFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.standard,
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      'Passer',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _OnboardingSlide(page: _pages[i]),
                  ),
                ),

                // Dots + buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    AppSpacing.lg,
                    AppSpacing.marginMobile,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: AppAnimations.fast,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _currentPage ? 24 : 8,
                            height: 4,
                            decoration: BoxDecoration(
                              color: i == _currentPage
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                              borderRadius: AppRadius.radiusFull,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // CTA buttons
                      PrimaryButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Commencer maintenant'
                            : 'Continuer',
                        onPressed: _nextPage,
                        icon: Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.rocket_launch_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.compact),
                      SecondaryButton(
                        label: 'J\'ai déjà un compte',
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _OnboardingSlide — single onboarding page
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background icon (dim)
                Icon(
                  page.backgroundIcon,
                  size: 140,
                  color: page.primaryColor.withOpacity(0.07),
                ),
                // Main icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: page.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(page.icon, size: 48, color: page.primaryColor),
                ),
                // Accent dot
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: page.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      page.backgroundIcon,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            page.title,
            style: AppTypography.h2.copyWith(
              color: AppColors.onSurface,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.compact),

          // Subtitle
          Text(
            page.subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tags row
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: page.tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.compact,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: AppRadius.radiusFull,
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Text(
                        t,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
