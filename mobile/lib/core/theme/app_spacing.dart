import 'package:flutter/material.dart';

/// BaaraLink Spacing System — 8px base grid
/// Source: Stitch DESIGN.md spacing tokens
abstract final class AppSpacing {
  // ─── Base tokens ─────────────────────────────────────────────────────────
  static const double xs = 4.0;   // space-4
  static const double sm = 8.0;   // space-8
  static const double md = 16.0;  // space-16 — gutter
  static const double lg = 24.0;  // space-24 — section gap
  static const double xl = 32.0;  // space-32 — major vertical

  // ─── Compound ─────────────────────────────────────────────────────────────
  static const double compact = 12.0;
  static const double spacious = 20.0;
  static const double generous = 40.0;
  static const double massive = 56.0;

  // ─── Layout ───────────────────────────────────────────────────────────────
  static const double marginMobile = 16.0;
  static const double marginDesktop = 48.0;
  static const double gutter = 16.0;
  static const double maxContentWidth = 600.0;

  // ─── Component-specific ───────────────────────────────────────────────────
  static const double buttonHeight = 52.0;       // min 48px touch target
  static const double inputHeight = 56.0;
  static const double avatarSm = 36.0;
  static const double avatarMd = 52.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 80.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double cardPaddingH = 16.0;
  static const double cardPaddingV = 16.0;
  static const double bottomNavHeight = 72.0;    // 52px bar + 20px safe area
  static const double topBarHeight = 56.0;
  static const double chipHeight = 32.0;
  static const double badgeHeight = 24.0;

  // ─── EdgeInsets helpers ───────────────────────────────────────────────────
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: marginMobile);
  static const EdgeInsets cardPadding = EdgeInsets.all(cardPaddingH);
  static const EdgeInsets buttonPaddingH = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: md, vertical: xs);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: md, vertical: compact);
  static const EdgeInsets sectionPadding = EdgeInsets.fromLTRB(marginMobile, lg, marginMobile, 0);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: marginMobile, vertical: compact);
  static const EdgeInsets modalPadding = EdgeInsets.fromLTRB(md, spacious, md, spacious);

  // ─── SizedBox helpers ─────────────────────────────────────────────────────
  static const Widget gapXs = SizedBox(height: xs, width: xs);
  static const Widget gapSm = SizedBox(height: sm, width: sm);
  static const Widget gapMd = SizedBox(height: md, width: md);
  static const Widget gapLg = SizedBox(height: lg, width: lg);
  static const Widget gapXl = SizedBox(height: xl, width: xl);
  static const Widget gapH4 = SizedBox(width: xs);
  static const Widget gapH8 = SizedBox(width: sm);
  static const Widget gapH12 = SizedBox(width: compact);
  static const Widget gapH16 = SizedBox(width: md);
  static const Widget gapV4 = SizedBox(height: xs);
  static const Widget gapV8 = SizedBox(height: sm);
  static const Widget gapV12 = SizedBox(height: compact);
  static const Widget gapV16 = SizedBox(height: md);
  static const Widget gapV24 = SizedBox(height: lg);
  static const Widget gapV32 = SizedBox(height: xl);
}
