import 'package:flutter/material.dart';

/// BaaraLink Design System — Color Tokens
/// Source: Modern Sahelian Professionalism — Stitch Export
/// Primary: Vibrant Orange (#994700) | Tertiary: Deep Blue (#006399)
abstract final class AppColors {
  // ─── Primary — Vibrant Orange ─────────────────────────────────────────────
  static const Color primary = Color(0xFF994700);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFF7A00);
  static const Color onPrimaryContainer = Color(0xFF5C2800);
  static const Color primaryFixed = Color(0xFFFFDBC8);
  static const Color primaryFixedDim = Color(0xFFFFB68B);
  static const Color onPrimaryFixed = Color(0xFF321200);
  static const Color onPrimaryFixedVariant = Color(0xFF753400);
  static const Color inversePrimary = Color(0xFFFFB68B);

  // ─── Secondary — Slate Blue ───────────────────────────────────────────────
  static const Color secondary = Color(0xFF535F6F);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD4E1F4);
  static const Color onSecondaryContainer = Color(0xFF576474);
  static const Color secondaryFixed = Color(0xFFD7E3F6);
  static const Color secondaryFixedDim = Color(0xFFBBC7DA);
  static const Color onSecondaryFixed = Color(0xFF101C2A);
  static const Color onSecondaryFixedVariant = Color(0xFF3C4857);

  // ─── Tertiary — Deep Blue ─────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF006399);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF00A8FF);
  static const Color onTertiaryContainer = Color(0xFF003A5C);
  static const Color tertiaryFixed = Color(0xFFCDE5FF);
  static const Color tertiaryFixedDim = Color(0xFF95CCFF);
  static const Color onTertiaryFixed = Color(0xFF001D32);
  static const Color onTertiaryFixedVariant = Color(0xFF004A75);

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ─── Success (custom) ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF1A7A3A);
  static const Color successContainer = Color(0xFFE8F5ED);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // ─── Warning (custom) ─────────────────────────────────────────────────────
  static const Color warning = Color(0xFFE65100);
  static const Color warningContainer = Color(0xFFFFF3E0);

  // ─── Surface / Background — Warm White ───────────────────────────────────
  static const Color surface = Color(0xFFFFF8F5);
  static const Color surfaceDim = Color(0xFFEDD5CA);
  static const Color surfaceBright = Color(0xFFFFF8F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFF1EA);
  static const Color surfaceContainer = Color(0xFFFFEADF);
  static const Color surfaceContainerHigh = Color(0xFFFBE3D7);
  static const Color surfaceContainerHighest = Color(0xFFF6DED2);
  static const Color onSurface = Color(0xFF251912);
  static const Color onSurfaceVariant = Color(0xFF584235);
  static const Color inverseSurface = Color(0xFF3B2D26);
  static const Color inverseOnSurface = Color(0xFFFFEDE5);
  static const Color background = Color(0xFFFFF8F5);
  static const Color onBackground = Color(0xFF251912);
  static const Color surfaceVariant = Color(0xFFF6DED2);
  static const Color surfaceTint = Color(0xFF994700);

  // ─── Outline ──────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF8C7263);
  static const Color outlineVariant = Color(0xFFE0C0AF);

  // ─── Dark Mode Surfaces ───────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceContainer = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF49454F);
  static const Color darkBackground = Color(0xFF0F0A07);

  // ─── Semantic Aliases ─────────────────────────────────────────────────────
  static const Color positiveGreen = Color(0xFF1B873F);
  static const Color positiveGreenContainer = Color(0xFFDCF2E5);
  static const Color negativeRed = error;
  static const Color premiumOrange = primaryContainer;
  static const Color verifiedBlue = tertiary;
  static const Color escrowGold = Color(0xFFD4A017);
  static const Color fcfaGold = Color(0xFFB8860B);

  // ─── Overlay / Scrim ──────────────────────────────────────────────────────
  static const Color scrim = Color(0x80251912);
  static const Color shimmerBase = Color(0xFFF0E8E0);
  static const Color shimmerHighlight = Color(0xFFF8EDE5);
}
