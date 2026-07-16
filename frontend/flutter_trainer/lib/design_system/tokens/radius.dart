import 'package:flutter/painting.dart';

/// Border-radius tokens. The trainer mock leans on Tailwind
/// `rounded-2xl` (~20px) for cards and pill shapes for chips/badges.
class AppRadius {
  AppRadius._();
  static const Radius xs = Radius.circular(6);
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius lg = Radius.circular(16);
  static const Radius card = Radius.circular(20); // tailwind rounded-2xl
  static const Radius pill = Radius.circular(999);
}
