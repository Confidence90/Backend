import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'shared/navigation/app_router.dart';
import 'shared/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: BaaraLinkApp()));
}

class BaaraLinkApp extends ConsumerWidget {
  const BaaraLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return MaterialApp.router(
      title: 'BaaraLink',
      debugShowCheckedModeBanner: false,

      // ── Theming ──────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Routing ──────────────────────────────────────────────────────────
      routerConfig: router,

      // ── Localization ─────────────────────────────────────────────────────
      // Must include GlobalMaterialLocalizations + GlobalCupertinoLocalizations
      // for Flutter to handle fr locale correctly
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'), // Français — primary
        Locale('en'), // English — fallback
      ],
      locale: const Locale('fr'),

      // ── Global builder — text scale clamping ─────────────────────────────
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.85, 1.25),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
