import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    const storage = FlutterSecureStorage();
    final token   = await storage.read(key: AppConstants.kAccessToken);
    final prefs   = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool(AppConstants.kOnboardingDone) ?? false;

    if (!mounted) return;
    if (token != null) {
      context.go(AppRoutes.home);
    } else if (!onboarded) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.xl,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('BL', style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -1,
                  )),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fade(duration: 400.ms),

              const SizedBox(height: 24),

              const Text(
                'BaaraLink',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              )
              .animate(delay: 300.ms)
              .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut)
              .fade(duration: 400.ms),

              const SizedBox(height: 8),

              const Text(
                'Trouvez. Travaillez. Réussissez.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              )
              .animate(delay: 500.ms)
              .fade(duration: 500.ms),

              const SizedBox(height: 60),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white60,
                    shape: BoxShape.circle,
                  ),
                )
                .animate(delay: (600 + i * 150).ms, onPlay: (c) => c.repeat())
                .scaleY(begin: 1, end: 1.5, duration: 400.ms, curve: Curves.easeInOut)
                .then()
                .scaleY(begin: 1.5, end: 1, duration: 400.ms)),
              )
              .animate(delay: 600.ms)
              .fade(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
