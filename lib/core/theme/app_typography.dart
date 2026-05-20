import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BaaraLink Typography System
/// Font: Inter — extracted from Stitch DESIGN.md
/// Scale: Material 3 mapped to Stitch spec tokens
abstract final class AppTypography {
  // ─── Base Font ────────────────────────────────────────────────────────────
  static TextStyle get _base => GoogleFonts.inter();

  // ─── Display / H1 ─────────────────────────────────────────────────────────
  /// 32px | Bold 700 | LineHeight 40px | LetterSpacing -0.02em
  static TextStyle get h1 => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25, // 40/32
        letterSpacing: -0.64, // -0.02em * 32
      );

  // ─── H2 ───────────────────────────────────────────────────────────────────
  /// 24px | Bold 700 | LineHeight 32px | LetterSpacing -0.01em
  static TextStyle get h2 => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33, // 32/24
        letterSpacing: -0.24,
      );

  // ─── H3 ───────────────────────────────────────────────────────────────────
  /// 20px | SemiBold 600 | LineHeight 28px
  static TextStyle get h3 => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0,
      );

  // ─── Body Large ───────────────────────────────────────────────────────────
  /// 18px | Regular 400 | LineHeight 28px
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.56,
        letterSpacing: 0,
      );

  // ─── Body Medium ──────────────────────────────────────────────────────────
  /// 16px | Regular 400 | LineHeight 24px
  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
      );

  // ─── Body Small ───────────────────────────────────────────────────────────
  /// 14px | Regular 400 | LineHeight 20px
  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0,
      );

  // ─── Label Caps ───────────────────────────────────────────────────────────
  /// 12px | Bold 700 | LineHeight 16px | LetterSpacing 0.05em
  static TextStyle get labelCaps => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: 0.6, // 0.05em * 12
      );

  // ─── Button ───────────────────────────────────────────────────────────────
  /// 16px | SemiBold 600 | LineHeight 20px
  static TextStyle get button => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0,
      );

  // ─── Caption ──────────────────────────────────────────────────────────────
  /// 11px | SemiBold 600 | LetterSpacing 0.03em
  static TextStyle get caption => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.45,
        letterSpacing: 0.33,
      );

  // ─── Overline ─────────────────────────────────────────────────────────────
  /// 10px | Bold 700 | LetterSpacing 0.08em | UPPERCASE
  static TextStyle get overline => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 1.6,
        letterSpacing: 0.8,
      );

  // ─── Amount / Price ───────────────────────────────────────────────────────
  /// 40px | Bold 700 | LetterSpacing -0.02em — for FCFA amounts
  static TextStyle get amountHero => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.8,
      );

  /// 28px | Bold 700 — for card amounts
  static TextStyle get amountLarge => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.14,
        letterSpacing: -0.56,
      );

  /// 18px | Bold 700 — for list amounts
  static TextStyle get amountMedium => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.22,
        letterSpacing: -0.18,
      );
}
