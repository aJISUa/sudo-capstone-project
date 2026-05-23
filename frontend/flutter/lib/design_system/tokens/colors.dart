import 'package:flutter/painting.dart';

/// Placeholder palette — values are taken from docs/DESIGN_TOKENS.md.
/// Real Figma values land in Stage 3.1.
class AppColors {
  AppColors._();

  // --- Brand ---
  static const Color primary = Color(0xFF3F8EFC);
  static const Color primaryContainer = Color(0xFFD9E8FF);
  static const Color secondary = Color(0xFF5FD3A4);
  static const Color accent = Color(0xFFFF8A65);

  // --- Semantic ---
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC05);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF4285F4);

  // --- Domain (Oncare-specific accents, used by feature cards) ---
  static const Color domainDiet = Color(0xFFFFB74D);
  static const Color domainExercise = Color(0xFF4DB6AC);
  static const Color domainHealth = Color(0xFF7986CB);
  static const Color domainAiCoach = Color(0xFF9575CD);
}
