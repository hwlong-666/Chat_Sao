import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color brandPrimary = Color(0xFF2D2D2D);
  static const Color brandSecondary = Color(0xFFF3F4F6);

  static const Color creamBackground = Color(0xFFFDFAF5);

  static const Color warmYellow = Color(0xFFFFEBB4);
  static const Color softPink = Color(0xFFFFBEBE);
  static const Color skyBlue = Color(0xFFA0D2FF);
  static const Color lavenderPink = Color(0xFFFFAADC);

  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color textMuted = Color(0xFFAAAAAA);

  static const Color white = Colors.white;
  static const Color white60 = Color(0x99FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color whiteBorder = Color(0x99FFFFFF);

  static const Color orange200 = Color(0xFFFFB86C);
  static const Color orange300 = Color(0xFFFFA040);
  static const Color orange400 = Color(0xFFFF8A50);
  static const Color redPink = Color(0xFFFF7A7A);
  static const Color redBadge = Color(0xFFFF5E5E);
  static const Color redBadgeLight = Color(0xFFFF8A8A);

  static const Color aiBubbleBg = Color(0xFF2D2D2D);
  static const Color orange200Text = Color(0xFFFFD0A0);

  static const Color onlineGreen = Color(0xFF22C55E);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);

  static Color glassColorWithOpacity(double opacity) {
    return Colors.white.withValues(alpha: opacity);
  }
}
