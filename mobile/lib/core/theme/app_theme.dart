import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────
abstract class AppColors {
  static const primary        = Color(0xFFFF6B00);
  static const primaryLight   = Color(0xFFFF8C3A);
  static const primaryDark    = Color(0xFFCC5500);
  static const primarySurface = Color(0xFFFFF0E6);

  static const background     = Color(0xFFF8F9FA);
  static const surface        = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0F2F5);
  static const border         = Color(0xFFE4E6EA);
  static const divider        = Color(0xFFF3F4F6);

  static const textPrimary    = Color(0xFF1E1E1E);
  static const textSecondary  = Color(0xFF6B7280);
  static const textTertiary   = Color(0xFF9CA3AF);
  static const textOnPrimary  = Color(0xFFFFFFFF);

  static const success        = Color(0xFF10B981);
  static const successSurface = Color(0xFFECFDF5);
  static const warning        = Color(0xFFF59E0B);
  static const warningSurface = Color(0xFFFFFBEB);
  static const error          = Color(0xFFEF4444);
  static const errorSurface   = Color(0xFFFEF2F2);
  static const info           = Color(0xFF3B82F6);
  static const infoSurface    = Color(0xFFEFF6FF);

  static const shimmerBase     = Color(0xFFE8E8E8);
  static const shimmerHighlight = Color(0xFFF5F5F5);
}

// ─── Spacing ─────────────────────────────────────────────────────────────────
abstract class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

// ─── Border Radius ────────────────────────────────────────────────────────────
abstract class AppRadius {
  static const sm   = BorderRadius.all(Radius.circular(8));
  static const md   = BorderRadius.all(Radius.circular(12));
  static const lg   = BorderRadius.all(Radius.circular(16));
  static const xl   = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
abstract class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const elevated = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const subtle = [
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}

// ─── Theme ───────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primarySurface,
        onPrimaryContainer: AppColors.primaryDark,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x14000000),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Card
      cardTheme: const CardTheme(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lg,
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: Color(0xFFE5E7EB),
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lg, borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg, borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins', color: AppColors.textTertiary, fontSize: 14,
        ),
        labelStyle: const TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primarySurface,
        checkmarkColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border, width: 1),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.full),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider, thickness: 1, space: 1,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displaySmall:  TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineMedium:TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge:    TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium:   TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleSmall:    TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge:     TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium:    TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodySmall:     TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge:    TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelMedium:   TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall:    TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      ),
    );
  }
}
