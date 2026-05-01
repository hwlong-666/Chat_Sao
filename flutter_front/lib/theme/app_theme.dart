import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.brandPrimary,
    scaffoldBackgroundColor: AppColors.creamBackground,
    colorScheme: ColorScheme.light(
      primary: AppColors.brandPrimary,
      secondary: AppColors.orange200,
      surface: AppColors.creamBackground,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: _fontFamily,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.orange200.withValues(alpha: 0.5), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 14,
        fontFamily: _fontFamily,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        fontFamily: _fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        fontFamily: _fontFamily,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        fontFamily: _fontFamily,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      elevation: 10,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.withValues(alpha: 0.1),
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static String get _fontFamily => 'Inter';
}
