import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// BaaraLink Motion & Animation System
/// Source: Stitch design spec — Motion & Animation section
abstract final class AppAnimations {
  // ─── Durations ────────────────────────────────────────────────────────────
  static const Duration micro =
      Duration(milliseconds: 100); // Button press scale
  static const Duration fast =
      Duration(milliseconds: 200); // Chip select, toggle
  static const Duration standard =
      Duration(milliseconds: 300); // Screen transition
  static const Duration emphasized =
      Duration(milliseconds: 400); // Modal slide-up
  static const Duration slow = Duration(milliseconds: 600); // Hero, splash
  static const Duration shimmer = Duration(milliseconds: 1400); // Shimmer loop

  // ─── Curves ───────────────────────────────────────────────────────────────
  /// Standard ease-out — screen push transitions
  static const Curve slideInCurve = Curves.easeOut;

  /// Material 3 emphasized — modals and bottom sheets
  static const Curve modalCurve = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Button press — quick snap
  static const Curve pressCurve = Curves.easeInOut;

  /// List items stagger base
  static const Curve itemCurve = Curves.easeOutCubic;

  /// Fade in
  static const Curve fadeCurve = Curves.easeIn;

  // ─── Scale factors ────────────────────────────────────────────────────────
  static const double buttonPressScale = 0.95;
  static const double cardPressScale = 0.98;
  static const double chipPressScale = 0.96;

  // ─── Stagger delays ───────────────────────────────────────────────────────
  static Duration stagger(int index,
          {Duration base = const Duration(milliseconds: 50)}) =>
      Duration(milliseconds: base.inMilliseconds * index);

  // ─── Page transitions ─────────────────────────────────────────────────────
  static CustomTransitionPage<T> slideTransition<T>({
    required LocalKey key,
    required Widget child,
  }) =>
      CustomTransitionPage<T>(
        key: key,
        child: child,
        transitionDuration: standard,
        reverseTransitionDuration: fast,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: slideInCurve));
          final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: fadeCurve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      );

  static CustomTransitionPage<T> fadeTransition<T>({
    required LocalKey key,
    required Widget child,
  }) =>
      CustomTransitionPage<T>(
        key: key,
        child: child,
        transitionDuration: standard,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation.drive(
            Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: fadeCurve)),
          ),
          child: child,
        ),
      );
}
