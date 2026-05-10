import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.backgroundSoft,
    required this.surface,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    required this.danger,
  });

  final Color background;
  final Color backgroundSoft;
  final Color surface;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textMuted;
  final Color border;
  final Color danger;

  @override
  AppPalette copyWith({
    Color? background,
    Color? backgroundSoft,
    Color? surface,
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? accent,
    Color? accentSoft,
    Color? textPrimary,
    Color? textMuted,
    Color? border,
    Color? danger,
  }) {
    return AppPalette(
      background: background ?? this.background,
      backgroundSoft: backgroundSoft ?? this.backgroundSoft,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundSoft: Color.lerp(backgroundSoft, other.backgroundSoft, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

class AppTheme {
  static const Color background = Color(0xFFF3FBF9);
  static const Color backgroundSoft = Color(0xFFDFF4EF);
  static const Color surface = Color(0xFFFFFEFC);
  static const Color primary = Color(0xFF146C72);
  static const Color primaryDark = Color(0xFF0C4A53);
  static const Color secondary = Color(0xFF4AA3A2);
  static const Color accent = Color(0xFFE7C96F);
  static const Color accentSoft = Color(0xFFF8EFCB);
  static const Color textPrimary = Color(0xFF183234);
  static const Color textMuted = Color(0xFF678086);
  static const Color border = Color(0xFFD8ECE7);
  static const Color danger = Color(0xFF46606A);

  static const AppPalette lightPalette = AppPalette(
    background: Color(0xFFF3FBF9),
    backgroundSoft: Color(0xFFDFF4EF),
    surface: Color(0xFFFFFEFC),
    primary: Color(0xFF146C72),
    primaryDark: Color(0xFF0C4A53),
    secondary: Color(0xFF4AA3A2),
    accent: Color(0xFFE7C96F),
    accentSoft: Color(0xFFF8EFCB),
    textPrimary: Color(0xFF183234),
    textMuted: Color(0xFF678086),
    border: Color(0xFFD8ECE7),
    danger: Color(0xFF46606A),
  );

  static const AppPalette darkPalette = AppPalette(
    background: Color(0xFF0D1618),
    backgroundSoft: Color(0xFF162528),
    surface: Color(0xFF1B2B2E),
    primary: Color(0xFF35B5B0),
    primaryDark: Color(0xFF1D7A80),
    secondary: Color(0xFF74D0C8),
    accent: Color(0xFFE7C96F),
    accentSoft: Color(0xFF4A4429),
    textPrimary: Color(0xFFF2FBF8),
    textMuted: Color(0xFFA5C0BC),
    border: Color(0xFF294146),
    danger: Color(0xFF9D6B73),
  );

  static AppPalette colorsOf(BuildContext context) {
    return Theme.of(context).extension<AppPalette>() ?? lightPalette;
  }

  static ThemeData light() => _buildTheme(lightPalette, Brightness.light);

  static ThemeData dark() => _buildTheme(darkPalette, Brightness.dark);

  static ThemeData _buildTheme(AppPalette palette, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: brightness,
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.surface,
      ),
    );

    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[palette],
      scaffoldBackgroundColor: palette.background,
      textTheme: base.textTheme.copyWith(
        displaySmall: TextStyle(
          fontSize: 36,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: palette.textPrimary,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: palette.textPrimary,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: palette.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.55,
          color: palette.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: palette.textMuted,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: palette.border),
        ),
      ),
      iconTheme: IconThemeData(color: palette.textPrimary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: TextStyle(color: palette.textMuted),
        labelStyle: TextStyle(color: palette.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.secondary.withValues(alpha: 0.16),
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        labelStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
