import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shared_widgets.dart';

class _Slide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  const _Slide({required this.emoji, required this.title, required this.subtitle, required this.bgColor});
}

const _slides = [
  _Slide(
    emoji: '🔍',
    title: 'Trouvez le bon prestataire',
    subtitle: 'Plombiers, électriciens, ménagères, maçons… tous vérifiés et notés par la communauté.',
    bgColor: Color(0xFFFFF0E6),
  ),
  _Slide(
    emoji: '⚡',
    title: 'Mission accomplie en quelques clics',
    subtitle: 'Publiez votre besoin, recevez des candidatures et payez en toute sécurité via Orange Money ou Wave.',
    bgColor: Color(0xFFEFF6FF),
  ),
  _Slide(
    emoji: '🌟',
    title: 'Développez votre carrière',
    subtitle: 'Créez votre profil, montrez vos compétences et décrochez des missions près de chez vous.',
    bgColor: Color(0xFFECFDF5),
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _page = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kOnboardingDone, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _page < 2
                    ? TextButton(
                        onPressed: _finish,
                        child: const Text('Passer', style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.w500, color: AppColors.textSecondary,
                        )),
                      )
                    : const SizedBox(height: 40),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (ctx, i) => _SlideWidget(slide: _slides[i], isActive: _page == i),
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? AppColors.primary : AppColors.border,
                        borderRadius: AppRadius.full,
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),

                  // CTA button
                  AppButton(
                    label: _page == _slides.length - 1 ? 'Commencer maintenant' : 'Suivant',
                    icon: _page == _slides.length - 1 ? null : Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_page < _slides.length - 1) {
                        _ctrl.nextPage(duration: 400.ms, curve: Curves.easeInOut);
                      } else {
                        _finish();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideWidget extends StatelessWidget {
  final _Slide slide;
  final bool isActive;
  const _SlideWidget({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container
          AnimatedContainer(
            duration: 400.ms,
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: slide.bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(slide.emoji, style: const TextStyle(fontSize: 80)),
            ),
          )
          .animate(target: isActive ? 1 : 0)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),

          const SizedBox(height: 48),

          Text(
            slide.title,
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 26,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          )
          .animate(target: isActive ? 1 : 0)
          .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
          .fade(duration: 400.ms),

          const SizedBox(height: 16),

          Text(
            slide.subtitle,
            style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 15,
              color: AppColors.textSecondary, height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
          .animate(target: isActive ? 1 : 0)
          .slideY(begin: 0.2, end: 0, duration: 450.ms, curve: Curves.easeOut, delay: 80.ms)
          .fade(duration: 400.ms, delay: 80.ms),
        ],
      ),
    );
  }
}
