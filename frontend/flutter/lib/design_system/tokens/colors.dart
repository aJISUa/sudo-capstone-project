import 'package:flutter/painting.dart';

/// Palette aligned with the original React prototype's `src/styles/theme.css`
/// (shadcn-style CSS variables). Light mode only for now — dark mode
/// follows the same shape and lands in a later phase.
class AppColors {
  AppColors._();

  // --- Brand ---
  /// `--primary` — bright teal-blue used for CTAs / active nav / accent
  /// fills throughout the app.
  static const Color primary = Color(0xFF3EAFDF);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// `--secondary` — deeper blue used as the second stop of the
  /// "today's record" gradient card.
  static const Color secondary = Color(0xFF277DA1);
  static const Color secondaryForeground = Color(0xFFFFFFFF);

  // --- Surface / text ---
  /// `--background`
  static const Color background = Color(0xFFFFFFFF);

  /// `--foreground` (oklch(0.145 0 0) ≈ #262626).
  static const Color foreground = Color(0xFF262626);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF262626);

  /// `--muted` — very soft blue tint used as fill for progress-bar tracks.
  static const Color muted = Color(0xFFE8F4F8);

  /// `--muted-foreground` — slate-500 ish.
  static const Color mutedForeground = Color(0xFF64748B);

  /// `--accent` — softer blue used as background for list rows /
  /// pills inside cards.
  static const Color accent = Color(0xFFE0F2F7);
  static const Color accentForeground = Color(0xFF0F172A);

  // --- Semantic ---
  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  /// `--warning` — orange used for "sodium too high" alerts and
  /// over-budget progress fills.
  static const Color warning = Color(0xFFF97316);
  static const Color warningForeground = Color(0xFFFFFFFF);

  // --- Borders & input ---
  /// `--border: rgba(0,0,0,0.1)`
  static const Color border = Color(0x1A000000);

  /// `--input-background`
  static const Color inputBackground = Color(0xFFF3F3F5);

  // --- Extra accents used by the gradient cards in the original. ---
  /// Used by the "이번 주 건강 점수" card (green gradient).
  static const Color scoreGradientStart = Color(
    0xFF22C55E,
  ); // tailwind green-500
  static const Color scoreGradientEnd = Color(0xFF059669); // emerald-600

  // --- Additional semantic aliases used by our reusable widgets
  // (AppBadge tones, MetricCard delta tones). The original React
  // app does not have explicit `success` / `info` tokens — these are
  // pragmatic additions kept in the same teal/orange/green family.
  static const Color success = scoreGradientStart;
  static const Color info = primary;
  static const Color error = destructive;
  static const Color primaryContainer = accent;
}
