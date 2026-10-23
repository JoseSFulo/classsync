import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static OutlineInputBorder _outline(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }

  static final ThemeData light = _build(
    const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2E7D6B),
      onPrimary: Colors.white,
      secondary: Color(0xFFF0A55B),
      onSecondary: Color(0xFF2A1A05),
      error: Color(0xFFC8473E),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1E2B28),
    ),
    AppColors.light,
    const Color(0xFFF3F7F5),
  );

  static final ThemeData dark = _build(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF5BBBA6),
      onPrimary: Color(0xFF0E1513),
      secondary: Color(0xFFF0A55B),
      onSecondary: Color(0xFF2A1A05),
      error: Color(0xFFF0776D),
      onError: Color(0xFF0E1513),
      surface: Color(0xFF1B2523),
      onSurface: Color(0xFFE8F0ED),
    ),
    AppColors.dark,
    const Color(0xFF111917),
  );

  static ThemeData _build(
    ColorScheme scheme,
    AppColors colors,
    Color background,
  ) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: background,
    );
    final text = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return base.copyWith(
      extensions: [colors],
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium!.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        titleMedium: text.titleMedium!.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        bodyMedium: text.bodyMedium!.copyWith(fontSize: 15),
        bodySmall: text.bodySmall!.copyWith(fontSize: 13, color: colors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.soft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? scheme.primary : colors.muted,
          );
        }),
      ),
      dividerTheme: DividerThemeData(color: colors.line, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        border: _outline(colors.line),
        enabledBorder: _outline(colors.line),
        focusedBorder: _outline(scheme.primary),
      ),
    );
  }
}
