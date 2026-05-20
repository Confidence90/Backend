import 'package:flutter/material.dart';

/// BaaraLink Border Radius System
/// Source: Stitch DESIGN.md — rounded tokens
abstract final class AppRadius {
  // ─── Tokens ───────────────────────────────────────────────────────────────
  static const double xs = 4.0;    // rounded-sm
  static const double sm = 8.0;    // rounded (DEFAULT)
  static const double md = 12.0;   // rounded-md — inputs, chips
  static const double lg = 16.0;   // rounded-lg — cards
  static const double xl = 24.0;   // rounded-xl — sheets, modals
  static const double full = 100.0; // pill — badges, buttons

  // ─── BorderRadius objects ─────────────────────────────────────────────────
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // ─── Bottom sheet ─────────────────────────────────────────────────────────
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  // ─── Top sheet ────────────────────────────────────────────────────────────
  static const BorderRadius topSheet = BorderRadius.only(
    bottomLeft: Radius.circular(xl),
    bottomRight: Radius.circular(xl),
  );

  // ─── Dialog ───────────────────────────────────────────────────────────────
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(28.0));
}
