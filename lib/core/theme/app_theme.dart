import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// BaaraLink App Theme — Material 3
/// Built from Modern Sahelian Professionalism design system
abstract final class AppTheme {
  // ─── Color Scheme — Light ─────────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    inversePrimary: AppColors.inversePrimary,
    surfaceTint: AppColors.surfaceTint,
    scrim: AppColors.scrim,
  );

  // ─── Color Scheme — Dark ──────────────────────────────────────────────────
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryFixedDim,
    onPrimary: AppColors.onPrimaryFixed,
    primaryContainer: AppColors.primary,
    onPrimaryContainer: AppColors.primaryFixed,
    secondary: AppColors.secondaryFixedDim,
    onSecondary: AppColors.onSecondaryFixed,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.secondaryFixed,
    tertiary: AppColors.tertiaryFixedDim,
    onTertiary: AppColors.onTertiaryFixed,
    tertiaryContainer: AppColors.tertiary,
    onTertiaryContainer: AppColors.tertiaryFixed,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceContainerHighest: AppColors.darkSurfaceContainerHigh,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outline: AppColors.darkOutline,
    outlineVariant: Color(0xFF534239),
    inverseSurface: AppColors.surfaceContainerHighest,
    onInverseSurface: AppColors.onSurface,
    inversePrimary: AppColors.primary,
    surfaceTint: AppColors.primaryFixedDim,
    scrim: Color(0xFF000000),
  );

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get light => _buildTheme(_lightColorScheme);

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => _buildTheme(_darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,

      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.outlineVariant.withOpacity(0.5),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.h3.copyWith(color: colorScheme.onSurface),
        toolbarHeight: AppSpacing.topBarHeight,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
        actionsIconTheme:
            IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
      ),

      // ── Text ──────────────────────────────────────────────────────────────
      textTheme: _buildTextTheme(colorScheme),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const StadiumBorder(),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
        ),
      ),

      // ── Input Decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.compact,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.bodySmall
            .copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        floatingLabelStyle:
            AppTypography.caption.copyWith(color: AppColors.primary),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:
            isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
          side: BorderSide(
            color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.surfaceContainer,
        selectedColor: AppColors.primary,
        labelStyle:
            AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        side: BorderSide(
          color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.compact),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ── NavigationBar (Material 3) ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryFixed,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(color: AppColors.primary);
          }
          return AppTypography.caption
              .copyWith(color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        titleTextStyle: AppTypography.h3.copyWith(color: colorScheme.onSurface),
        contentTextStyle: AppTypography.bodyMedium
            .copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
        modalBackgroundColor:
            isDark ? AppColors.darkSurface : AppColors.surfaceContainerLowest,
        showDragHandle: true,
        dragHandleColor:
            isDark ? AppColors.darkOutline : AppColors.outlineVariant,
        dragHandleSize: const Size(32, 4),
        elevation: 0,
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle:
            AppTypography.bodySmall.copyWith(color: AppColors.inverseOnSurface),
        actionTextColor: AppColors.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        behavior: SnackBarBehavior.floating,
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.compact,
        ),
        titleTextStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        iconColor: colorScheme.onSurfaceVariant,
        minLeadingWidth: 24,
        dense: false,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onPrimary;
          return isDark ? AppColors.darkOnSurface : AppColors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return isDark
              ? AppColors.darkSurfaceContainerHigh
              : AppColors.surfaceContainerHighest;
        }),
      ),
    );
  }

  // ─── Text Theme Builder ───────────────────────────────────────────────────
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final color = colorScheme.onSurface;
    final secondary = colorScheme.onSurfaceVariant;
    return TextTheme(
      displayLarge: AppTypography.h1.copyWith(color: color),
      displayMedium: AppTypography.h2.copyWith(color: color),
      displaySmall: AppTypography.h3.copyWith(color: color),
      headlineLarge: AppTypography.h1.copyWith(color: color),
      headlineMedium: AppTypography.h2.copyWith(color: color),
      headlineSmall: AppTypography.h3.copyWith(color: color),
      titleLarge: AppTypography.h3.copyWith(color: color),
      titleMedium: AppTypography.bodyLarge
          .copyWith(fontWeight: FontWeight.w600, color: color),
      titleSmall: AppTypography.bodyMedium
          .copyWith(fontWeight: FontWeight.w600, color: color),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: color),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: color),
      bodySmall: AppTypography.bodySmall.copyWith(color: secondary),
      labelLarge: AppTypography.button.copyWith(color: color),
      labelMedium: AppTypography.caption.copyWith(color: secondary),
      labelSmall: AppTypography.overline.copyWith(color: secondary),
    );
  }
}
