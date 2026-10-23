import 'package:flutter/material.dart';

/// Colors that Material's ColorScheme has no slot for.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.muted,
    required this.soft,
    required this.line,
    required this.accent,
    required this.classColors,
  });

  final Color muted;
  final Color soft;
  final Color line;
  final Color accent;

  /// The five colors a class can be tagged with. Saved by index.
  final List<Color> classColors;

  static const light = AppColors(
    muted: Color(0xFF667873),
    soft: Color(0xFFE1F0EB),
    line: Color(0xFFE0E8E5),
    accent: Color(0xFFF0A55B),
    classColors: [
      Color(0xFF2E7D6B),
      Color(0xFF4A7FD1),
      Color(0xFFE08A3C),
      Color(0xFFB867C6),
      Color(0xFFD9576B),
    ],
  );

  static const dark = AppColors(
    muted: Color(0xFF93A59F),
    soft: Color(0xFF20332E),
    line: Color(0xFF2A3734),
    accent: Color(0xFFF0A55B),
    classColors: [
      Color(0xFF5BBBA6),
      Color(0xFF7FA8EA),
      Color(0xFFEBA262),
      Color(0xFFCF8EDB),
      Color(0xFFEA8294),
    ],
  );

  @override
  AppColors copyWith({
    Color? muted,
    Color? soft,
    Color? line,
    Color? accent,
    List<Color>? classColors,
  }) {
    return AppColors(
      muted: muted ?? this.muted,
      soft: soft ?? this.soft,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      classColors: classColors ?? this.classColors,
    );
  }

  // We never animate between light and dark, so just switch at the halfway point.
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
