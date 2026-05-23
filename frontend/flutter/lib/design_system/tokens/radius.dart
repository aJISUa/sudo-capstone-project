import 'package:flutter/painting.dart';

/// Border-radius tokens aligned with the original prototype.
/// `--radius` in the shadcn theme is `0.625rem` (10px). Cards in the
/// React app use Tailwind `rounded-2xl` which renders ~20px.
class AppRadius {
  AppRadius._();
  static const Radius xs = Radius.circular(6);
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(10); // shadcn base radius
  static const Radius lg = Radius.circular(14);
  static const Radius xl = Radius.circular(16);
  static const Radius card = Radius.circular(20); // tailwind rounded-2xl
  static const Radius pill = Radius.circular(999);
}
