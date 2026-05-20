import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/jobs/presentation/pages/jobs_list_page.dart';
import '../../features/jobs/presentation/pages/job_detail_page.dart';
import '../../features/jobs/presentation/pages/job_create_page.dart';
import '../../features/profile/presentation/pages/my_profile_page.dart';
import '../../features/profile/presentation/pages/profile_view_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final token   = await storage.read(key: AppConstants.kAccessToken);
      final isLoggedIn = token != null;
      final prefs   = await SharedPreferences.getInstance();
      final onboarded = prefs.getBool(AppConstants.kOnboardingDone) ?? false;

      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash   = state.matchedLocation == AppRoutes.splash;

      if (isSplash) return null;
      if (!isLoggedIn && !isAuthRoute) {
        return onboarded ? AppRoutes.login : AppRoutes.onboarding;
      }
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash,     builder: (_, __) => const SplashPage()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingPage()),
      GoRoute(path: AppRoutes.login,      builder: (_, __) => const LoginPage()),
      GoRoute(path: AppRoutes.register,   builder: (_, __) => const RegisterPage()),
      GoRoute(
        path: AppRoutes.otpVerify,
        builder: (_, s) => OtpPage(
          phone:     s.uri.queryParameters['phone']      ?? '',
          purpose:   s.uri.queryParameters['purpose']    ?? 'login',
          firstName: s.uri.queryParameters['first_name'],
          lastName:  s.uri.queryParameters['last_name'],
          role:      s.uri.queryParameters['role'],
        ),
      ),

      // Authenticated shell
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home,      builder: (_, __) => const HomePage()),
          GoRoute(path: AppRoutes.jobList,   builder: (_, __) => const JobsListPage()),
          GoRoute(path: AppRoutes.profileMe, builder: (_, __) => const MyProfilePage()),
          // Chat tab placeholder
          GoRoute(path: AppRoutes.chat, builder: (_, __) => const _ChatPlaceholder()),
        ],
      ),

      // Detail pages (outside shell - full screen)
      GoRoute(
        path: '/jobs/create',
        builder: (_, __) => const JobCreatePage(),
      ),
      GoRoute(
        path: '/jobs/:id',
        builder: (_, s) => JobDetailPage(jobId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (_, s) => ProfileViewPage(profileId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfilePage(),
      ),
    ],
    errorBuilder: (_, s) => Scaffold(
      body: Center(child: Text('Page introuvable: ${s.error}')),
    ),
  );
});

class _ChatPlaceholder extends StatelessWidget {
  const _ChatPlaceholder();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('💬', style: TextStyle(fontSize: 64)),
        SizedBox(height: 16),
        Text('Messagerie', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('Disponible dans la prochaine version', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF6B7280))),
      ],
    )),
  );
}
