import 'package:material_ui/material_ui.dart';

/// The four visual themes from the design brief.
enum AppThemeId { emeraldGold, cream, ocean, sunset }

class AppPalette {
  const AppPalette({
    required this.id,
    required this.brightness,
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.onSurface,
  });

  final AppThemeId id;
  final Brightness brightness;
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color onSurface;

  static const emeraldGold = AppPalette(
    id: AppThemeId.emeraldGold,
    brightness: Brightness.dark,
    primary: Color(0xFF0E7A5A),
    accent: Color(0xFFD4AF37),
    background: Color(0xFF06231B),
    surface: Color(0xFF0B3328),
    onSurface: Color(0xFFF3EBD3),
  );

  static const cream = AppPalette(
    id: AppThemeId.cream,
    brightness: Brightness.light,
    primary: Color(0xFF6B5A2E),
    accent: Color(0xFFC9A44C),
    background: Color(0xFFFAF6EC),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF2E2A20),
  );

  static const ocean = AppPalette(
    id: AppThemeId.ocean,
    brightness: Brightness.dark,
    primary: Color(0xFF1FB5B0),
    accent: Color(0xFF7FE3DF),
    background: Color(0xFF0A1A33),
    surface: Color(0xFF112747),
    onSurface: Color(0xFFF2F7FF),
  );

  static const sunset = AppPalette(
    id: AppThemeId.sunset,
    brightness: Brightness.dark,
    primary: Color(0xFFE8833A),
    accent: Color(0xFFFFC27A),
    background: Color(0xFF1E1436),
    surface: Color(0xFF2C1E4A),
    onSurface: Color(0xFFFFF1E6),
  );

  /// Sleep-mode palette: very dark, low-contrast-glare.
  static const sleep = AppPalette(
    id: AppThemeId.emeraldGold,
    brightness: Brightness.dark,
    primary: Color(0xFF2F5D50),
    accent: Color(0xFF9C8640),
    background: Color(0xFF000000),
    surface: Color(0xFF0A0F0D),
    onSurface: Color(0xFF8E9A93),
  );

  static AppPalette of(AppThemeId id) => switch (id) {
        AppThemeId.emeraldGold => emeraldGold,
        AppThemeId.cream => cream,
        AppThemeId.ocean => ocean,
        AppThemeId.sunset => sunset,
      };
}

class AppTheme {
  AppTheme._();

  static ThemeData build(AppPalette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: Colors.white,
      secondary: p.accent,
      onSecondary: p.brightness == Brightness.dark ? Colors.black : Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: p.surface,
      onSurface: p.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: p.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: p.surface.withValues(alpha: 0.82),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      listTileTheme: ListTileThemeData(iconColor: p.accent),
      // Visible focus for Android TV remote navigation.
      focusColor: p.accent.withValues(alpha: 0.35),
      visualDensity: VisualDensity.standard,
    );
  }
}
