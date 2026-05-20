import 'package:flutter/material.dart';
import 'app_colors.dart';

/// BaaraLink Elevation & Shadow System
/// Low-opacity single-direction shadows for clean flat-ish look
abstract final class AppShadows {
  // ─── Soft ambient card shadow ─────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D251912), // 5% on-surface
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  // ─── Elevated component (FAB, modal trigger) ──────────────────────────────
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A251912), // 10% on-surface
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: -4,
    ),
  ];

  // ─── Primary CTA button glow ──────────────────────────────────────────────
  static const List<BoxShadow> primaryButtonShadow = [
    BoxShadow(
      color: Color(0x4D994700), // 30% primary
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
  ];

  // ─── Wallet / Revenue card ────────────────────────────────────────────────
  static const List<BoxShadow> walletCardShadow = [
    BoxShadow(
      color: Color(0x4D994700), // 30% primary orange
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -6,
    ),
  ];

  // ─── Bottom nav shadow ────────────────────────────────────────────────────
  static const List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: Color(0x14251912),
      blurRadius: 12,
      offset: Offset(0, -2),
      spreadRadius: 0,
    ),
  ];

  // ─── Toast / Snackbar shadow ──────────────────────────────────────────────
  static const List<BoxShadow> toastShadow = [
    BoxShadow(
      color: Color(0x29251912),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  // ─── No shadow (flat) ─────────────────────────────────────────────────────
  static const List<BoxShadow> none = [];
}
