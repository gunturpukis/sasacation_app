import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
 
/// AppTheme — sumber kebenaran tunggal untuk semua token visual di app.
///
/// PERUBAHAN BESAR dari versi sebelumnya: file ini sekarang mengikuti
/// DESIGN.md dari design system "Sasacation" (Stitch export) secara persis —
/// bukan cuma primary/secondary color lagi, tapi skema M3 penuh (surface
/// tiers, outline, tertiary, dst) + tipografi Plus Jakarta Sans + token
/// radius/shadow yang dipakai konsisten di semua widget baru.
///
/// primaryColor & secondaryColor SENGAJA dipertahankan nilai lamanya
/// (#008080, #FF6B35) karena sudah persis sama dengan token `primary-container`
/// & `secondary-container` di DESIGN.md — tidak ada breaking change warna
/// untuk kode lama yang masih mereferensikan AppTheme.primaryColor langsung.
class AppTheme {
  // ─── Warna inti (dipertahankan, sudah sesuai DESIGN.md) ───────────────────
  static const Color primaryColor = Color(0xFF008080); // primary-container
  static const Color secondaryColor = Color(0xFFFF6B35); // dekat secondary-container (#fe6a34)
  static const Color accentColor = Color(0xFF00A896);
 
  // ─── Skema warna M3 lengkap dari DESIGN.md ─────────────────────────────────
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceDim = Color(0xFFDCD9D9);
  static const Color surfaceBright = Color(0xFFFCF9F8);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E1);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF3E4949);
  static const Color inverseSurface = Color(0xFF303030);
  static const Color inverseOnSurface = Color(0xFFF3F0EF);
  static const Color outline = Color(0xFF6E7979);
  static const Color outlineVariant = Color(0xFFBDC9C8);
 
  static const Color primary = Color(0xFF006565);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color onPrimaryContainer = Color(0xFFE3FFFE);
  static const Color inversePrimary = Color(0xFF76D6D5);
 
  static const Color secondary = Color(0xFFAB3500);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFE6A34);
  static const Color onSecondaryContainer = Color(0xFF5D1900);
 
  static const Color tertiary = Color(0xFF00665A); // dipakai untuk fitur AI ("Sasa AI")
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF008173);
  static const Color onTertiaryContainer = Color(0xFFE4FFF8);
 
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
 
  // ─── Fungsional accent (dari DESIGN.md bagian "Functional Accents") ───────
  static const Color successColor = Color(0xFF1B8A5A); // badge/"top-rated"
  static const Color loveColor = Color(0xFFEA4335); // wishlist aktif
  static const Color ratingColor = Color(0xFFFFC107); // bintang rating
 
  static const Color backgroundColor = surface;
  static const Color surfaceColor = surfaceContainerLowest;
 
  // ─── Radius (dari DESIGN.md `rounded`) ─────────────────────────────────────
  static const double radiusSm = 4;
  static const double radiusDefault = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;
  // Radius spesifik yang disebut eksplisit di DESIGN.md bagian "Shapes"
  static const double radiusButton = 15; // "Standard Elements: 15px radius"
  static const double radiusCard = 20; // "Product Cards: 20px rounded corners"
  static const double radiusSheet = 24; // bottom sheet / container besar, sisi atas
 
  // ─── Spacing (dari DESIGN.md `spacing`) ────────────────────────────────────
  static const double spacingBaseline = 4;
  static const double spacingGutter = 16;
  static const double spacingMarginMobile = 20;
  static const double spacingSectionGap = 28;
 
  // ─── Shadow (dari DESIGN.md "Elevation & Depth") ───────────────────────────
  // "extremely soft, low-opacity shadows (Black 5%, Blur 10px, Offset Y=2)"
  static List<BoxShadow> get softCardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
 
  // Untuk elemen "floating"/sticky (search bar, bottom bar) — elevasi lebih tinggi
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
 
  // Gradient bottom-up untuk overlay teks di atas gambar (Product Cards)
  static const LinearGradient imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.transparent, Color(0x9C000000)],
    stops: [0.0, 0.4, 1.0],
  );
 
  static ThemeData light() {
    final textTheme = _buildTextTheme();
 
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface.withOpacity(0.8),
        foregroundColor: onSurface,
        titleTextStyle: textTheme.headlineMedium?.copyWith(color: primary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        color: surfaceContainerLowest,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: primaryContainer, width: 1.5),
        ),
        hintStyle: TextStyle(color: outline, fontFamily: GoogleFonts.plusJakartaSans().fontFamily),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      // Tombol CTA hero (orange) tidak punya ThemeData bawaan Flutter —
      // dipakai lewat AppTheme.heroButtonStyle di widget yang butuh (lihat
      // pill_badge.dart & widget lain di lib/ui/widget/)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        selectedItemColor: primaryContainer,
        unselectedItemColor: outline,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
 
  // Style tombol hero CTA orange — dipakai eksplisit (bukan lewat Theme)
  // karena Flutter cuma punya 1 slot ElevatedButtonThemeData per app, dan
  // primary button (teal) sudah pakai slot itu.
  static ButtonStyle heroButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryContainer,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
  );
 
  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base.copyWith(
      // display-lg: 32/40, 700
      displayLarge: base.displayLarge?.copyWith(
          fontSize: 32, fontWeight: FontWeight.w700, height: 40 / 32, color: onSurface),
      // headline-lg: 28/36, 700
      headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 28, fontWeight: FontWeight.w700, height: 36 / 28, color: onSurface),
      // headline-md: 24/32, 700 (juga dipakai untuk headline-lg-mobile, sama persis nilainya)
      headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 24, fontWeight: FontWeight.w700, height: 32 / 24, color: onSurface),
      // title-lg: 18/24, 600
      titleLarge: base.titleLarge?.copyWith(
          fontSize: 18, fontWeight: FontWeight.w600, height: 24 / 18, color: onSurface),
      // body-lg: 16/24, 400
      bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16, color: onSurface),
      // body-md: 14/20, 400
      bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14, color: onSurfaceVariant),
      // label-sm: 12/16, 600, letterSpacing 0.05em (~0.6px @ 12px)
      labelSmall: base.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          letterSpacing: 0.6,
          color: onSurfaceVariant),
      labelLarge: base.labelLarge?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    );
  }
}
 