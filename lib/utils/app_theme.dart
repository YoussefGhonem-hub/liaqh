import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ── Adaptive color extension ───────────────────────────────────────────────────
// Access via: context.colors.bg, context.colors.card, etc.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color listTile;
  final Color fg;
  final Color subFg;
  final Color mutedFg;
  final Color divider;
  final Color shadow;
  final Color inputFill;
  final Color chipSelected;
  final Color chipUnselected;

  const AppThemeColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.listTile,
    required this.fg,
    required this.subFg,
    required this.mutedFg,
    required this.divider,
    required this.shadow,
    required this.inputFill,
    required this.chipSelected,
    required this.chipUnselected,
  });

  static const light = AppThemeColors(
    bg:            Color(0xFFFFFFFF),
    surface:       Color(0xFFFFFFFF),
    card:          Color(0xFFFFFFFF),
    listTile:      Color(0xFFF7F8F8),
    fg:            Color(0xFF1D1617),
    subFg:         Color(0xFF7B6F72),
    mutedFg:       Color(0xFFADA4A5),
    divider:       Color(0x1F000000),
    shadow:        Color(0x1F000000),
    inputFill:     Color(0xFFF7F8F8),
    chipSelected:  Color(0xFFD97757),
    chipUnselected:Color(0xFFF0F0F0),
  );

  static const dark = AppThemeColors(
    bg:            Color(0xFF0F0F0F),
    surface:       Color(0xFF1A1A1A),
    card:          Color(0xFF242424),
    listTile:      Color(0xFF2A2A2A),
    fg:            Color(0xFFF2F2F2),
    subFg:         Color(0xFFB0A8A9),
    mutedFg:       Color(0xFF6E6A6B),
    divider:       Color(0x33FFFFFF),
    shadow:        Color(0x66000000),
    inputFill:     Color(0xFF2A2A2A),
    chipSelected:  Color(0xFFD97757),
    chipUnselected:Color(0xFF2E2E2E),
  );

  @override
  AppThemeColors copyWith({
    Color? bg, Color? surface, Color? card, Color? listTile,
    Color? fg, Color? subFg, Color? mutedFg, Color? divider,
    Color? shadow, Color? inputFill, Color? chipSelected, Color? chipUnselected,
  }) => AppThemeColors(
    bg:             bg            ?? this.bg,
    surface:        surface       ?? this.surface,
    card:           card          ?? this.card,
    listTile:       listTile      ?? this.listTile,
    fg:             fg            ?? this.fg,
    subFg:          subFg         ?? this.subFg,
    mutedFg:        mutedFg       ?? this.mutedFg,
    divider:        divider       ?? this.divider,
    shadow:         shadow        ?? this.shadow,
    inputFill:      inputFill     ?? this.inputFill,
    chipSelected:   chipSelected  ?? this.chipSelected,
    chipUnselected: chipUnselected?? this.chipUnselected,
  );

  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      bg:             Color.lerp(bg,            other.bg,            t)!,
      surface:        Color.lerp(surface,       other.surface,       t)!,
      card:           Color.lerp(card,          other.card,          t)!,
      listTile:       Color.lerp(listTile,      other.listTile,      t)!,
      fg:             Color.lerp(fg,            other.fg,            t)!,
      subFg:          Color.lerp(subFg,         other.subFg,         t)!,
      mutedFg:        Color.lerp(mutedFg,       other.mutedFg,       t)!,
      divider:        Color.lerp(divider,       other.divider,       t)!,
      shadow:         Color.lerp(shadow,        other.shadow,        t)!,
      inputFill:      Color.lerp(inputFill,     other.inputFill,     t)!,
      chipSelected:   Color.lerp(chipSelected,  other.chipSelected,  t)!,
      chipUnselected: Color.lerp(chipUnselected,other.chipUnselected,t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// ── Theme builder ─────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark()  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final ext    = isDark ? AppThemeColors.dark : AppThemeColors.light;

    final cs = ColorScheme.fromSeed(
      seedColor:  AppColors.primaryColor1,
      brightness: brightness,
      primary:    AppColors.primaryColor1,
      secondary:  AppColors.primaryColor2,
      error:      AppColors.errorColor,
      surface:    ext.surface,
    ).copyWith(
      onPrimary:  Colors.white,
      onSurface:  ext.fg,
    );

    final base = ThemeData(
      useMaterial3:          true,
      colorScheme:           cs,
      brightness:            brightness,
      scaffoldBackgroundColor: ext.bg,
      cardColor:             ext.card,
      dividerColor:          ext.divider,
      extensions:            [ext],
    );

    final cairoText = GoogleFonts.cairoTextTheme(base.textTheme).copyWith(
      displayLarge:  GoogleFonts.cairo(fontSize: 57, fontWeight: FontWeight.w800, color: ext.fg),
      headlineLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w800, color: ext.fg),
      headlineMedium:GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: ext.fg),
      titleLarge:    GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: ext.fg),
      titleMedium:   GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: ext.fg),
      titleSmall:    GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: ext.fg),
      bodyLarge:     GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: ext.fg),
      bodyMedium:    GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: ext.fg),
      bodySmall:     GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: ext.subFg),
      labelLarge:    GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: ext.fg),
    );

    return base.copyWith(
      textTheme:        cairoText,
      primaryTextTheme: cairoText,
      appBarTheme: AppBarTheme(
        backgroundColor:  ext.bg,
        foregroundColor:  ext.fg,
        elevation:        0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cairo(
            fontSize: 17, fontWeight: FontWeight.w700, color: ext.fg),
        iconTheme: IconThemeData(color: ext.fg),
      ),
      cardTheme: CardThemeData(
        color:       ext.card,
        surfaceTintColor: Colors.transparent,
        elevation:   0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   ext.inputFill,
        hintStyle:   GoogleFonts.cairo(fontSize: 14, color: ext.subFg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor1,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primaryColor1
                : ext.mutedFg),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primaryColor1.withValues(alpha: 0.4)
                : ext.listTile),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      ext.surface,
        selectedItemColor:    AppColors.primaryColor1,
        unselectedItemColor:  ext.subFg,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor:          AppColors.primaryColor1,
        unselectedLabelColor: ext.subFg,
        indicatorColor:      AppColors.primaryColor1,
        dividerColor:        Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color:   ext.card,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ext.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: ext.fg),
        contentTextStyle: GoogleFonts.cairo(fontSize: 14, color: ext.subFg),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? ext.card : AppColors.blackColor,
        contentTextStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: ListTileThemeData(
        tileColor:     Colors.transparent,
        iconColor:     AppColors.primaryColor1,
        textColor:     ext.fg,
        subtitleTextStyle: GoogleFonts.cairo(fontSize: 12, color: ext.subFg),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:    ext.chipUnselected,
        selectedColor:      AppColors.primaryColor1,
        labelStyle:         GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        side:               BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
