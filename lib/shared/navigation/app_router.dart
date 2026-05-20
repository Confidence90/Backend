import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/home/screens/provider_dashboard_screen.dart';
import '../../features/home/screens/client_dashboard_screen.dart';
import '../../features/marketplace/screens/search_screen.dart';
import '../../features/marketplace/screens/artisan_profile_screen.dart';
import '../../features/missions/screens/post_mission_screen.dart';
import '../../features/missions/screens/mission_detail_screen.dart' show MissionsListScreen, ActiveMissionsScreen, MissionDetailScreen;
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/wallet/screens/payment_screen.dart';
import '../../features/chat/screens/chat_screens.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/identity_verification_screen.dart';
import '../../features/packs/screens/packs_screen.dart';
import '../../features/marketplace/screens/favorites_screen.dart';
import '../../features/marketplace/screens/applications_screen.dart';
import '../../features/missions/screens/earnings_screen.dart';
import '../../features/missions/screens/reviews_screen.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/models/app_models.dart';
import '../../core/theme/app_animations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route constants
// ─────────────────────────────────────────────────────────────────────────────
import 'app_routes.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Page transition helpers
// ─────────────────────────────────────────────────────────────────────────────
CustomTransitionPage<T> _slide<T>(LocalKey key, Widget child) =>
    CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: AppAnimations.standard,
      reverseTransitionDuration: AppAnimations.fast,
      transitionsBuilder: (ctx, animation, secondary, child) {
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: AppAnimations.slideInCurve));
        final fade = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.0, 0.7)));
        return SlideTransition(
          position: animation.drive(slide),
          child: FadeTransition(opacity: animation.drive(fade), child: child),
        );
      },
    );

CustomTransitionPage<T> _fade<T>(LocalKey key, Widget child) =>
    CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: AppAnimations.standard,
      transitionsBuilder: (ctx, animation, _, child) => FadeTransition(
        opacity: animation.drive(
            Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeIn))),
        child: child,
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Router provider
// ─────────────────────────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // ── Auth redirect guard ──────────────────────────────────────────────
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      final isAuthRoute = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.otp,
        AppRoutes.roleSelect,
      ].any((r) => location.startsWith(r.replaceAll(':id', '')));

      // Still initializing — stay on splash
      if (auth is AuthInitial) return AppRoutes.splash;

      // Not logged in and trying to access protected route
      if (auth is AuthUnauthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Logged in and trying to access auth routes (except splash for redirect)
      if (auth is AuthAuthenticated && isAuthRoute && location != AppRoutes.splash) {
        final user = auth.user;
        return user.role == UserRole.provider
            ? AppRoutes.providerDashboard
            : AppRoutes.clientDashboard;
      }

      return null;
    },

    // ── Error page ────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Page introuvable', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),

    routes: [
      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (ctx, s) => _fade(s.pageKey, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.otp,
        pageBuilder: (ctx, s) => _slide(s.pageKey,
            OtpScreen(phone: s.uri.queryParameters['phone'] ?? '')),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const RoleSelectScreen()),
      ),

      // ── Provider ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.providerDashboard,
        pageBuilder: (ctx, s) => _fade(s.pageKey, const ProviderDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.missionsList,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const MissionsListScreen()),
      ),
      GoRoute(
        path: AppRoutes.activeMissions,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const ActiveMissionsScreen()),
      ),
      GoRoute(
        path: AppRoutes.earnings,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const EarningsScreen()),
      ),
      GoRoute(
        path: AppRoutes.reviews,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const ReviewsScreen()),
      ),

      // ── Client ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.clientDashboard,
        pageBuilder: (ctx, s) => _fade(s.pageKey, const ClientDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.postMission,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const PostMissionScreen()),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const FavoritesScreen()),
      ),
      GoRoute(
        path: AppRoutes.applications,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const ApplicationsScreen()),
      ),

      // ── Shared marketplace ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (ctx, s) => _slide(s.pageKey, SearchScreen(
          initialQuery: s.uri.queryParameters['q'],
          category: s.uri.queryParameters['category'],
        )),
      ),
      GoRoute(
        path: AppRoutes.artisanProfile,
        pageBuilder: (ctx, s) => _slide(s.pageKey,
            ArtisanProfileScreen(artisanId: s.pathParameters['id']!)),
      ),
      GoRoute(
        path: AppRoutes.missionDetail,
        pageBuilder: (ctx, s) => _slide(s.pageKey,
            MissionDetailScreen(missionId: s.pathParameters['id']!)),
      ),

      // ── Wallet & Payments ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.wallet,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const WalletScreen()),
      ),
      GoRoute(
        path: AppRoutes.payment,
        pageBuilder: (ctx, s) => _slide(s.pageKey, PaymentScreen(
          amount: int.tryParse(s.uri.queryParameters['amount'] ?? '0') ?? 0,
          missionTitle: s.uri.queryParameters['title'],
        )),
      ),

      // ── Chat ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.chatList,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const ChatListScreen()),
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        pageBuilder: (ctx, s) => _slide(s.pageKey,
            ChatRoomScreen(chatId: s.pathParameters['id']!)),
      ),

      // ── Notifications ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const NotificationsScreen()),
      ),

      // ── Profile ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const EditProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.idVerification,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const IdentityVerificationScreen()),
      ),

      // ── Packs ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.packs,
        pageBuilder: (ctx, s) => _slide(s.pageKey, const PacksScreen()),
      ),
    ],
  );
});
