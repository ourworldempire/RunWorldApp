import 'package:flutter/services.dart';

class AppHaptics {
  AppHaptics._();

  static void light()     => HapticFeedback.lightImpact();
  static void medium()    => HapticFeedback.mediumImpact();
  static void heavy()     => HapticFeedback.heavyImpact();
  static void selection() => HapticFeedback.selectionClick();

  // Double-tap heavy for level-up / territory capture
  static Future<void> celebrate() async {
    HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    HapticFeedback.heavyImpact();
  }
}
