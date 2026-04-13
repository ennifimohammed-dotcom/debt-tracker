import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const primary   = Color(0xFF1A237E);
  static const primaryM  = Color(0xFF283593);
  static const primaryL  = Color(0xFF3949AB);
  static const accent    = Color(0xFF00ACC1);
  static const bg        = Color(0xFFF0F2F5);
  static const unpaid    = Color(0xFFE53935);
  static const unpaidBg  = Color(0xFFFFEBEE);
  static const partial   = Color(0xFFFB8C00);
  static const partialBg = Color(0xFFFFF8E1);
  static const paid      = Color(0xFF2E7D32);
  static const paidBg    = Color(0xFFE8F5E9);
  static const gold      = Color(0xFFFFD54F);

  static const LinearGradient headerGrad = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF0D47A1)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient unpaidGrad = LinearGradient(
    colors: [Color(0xFFEF9A9A), Color(0xFFE53935)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient partialGrad = LinearGradient(
    colors: [Color(0xFFFFCC80), Color(0xFFFB8C00)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient paidGrad = LinearGradient(
    colors: [Color(0xFFA5D6A7), Color(0xFF2E7D32)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}

class MAD {
  static String fmt(double v)      => '${_f(v)} درهم';
  static String fmtShort(double v) => '${_s(v)} درهم';
  static String num(double v)      => _f(v);

  static String _f(double v) {
    final a = v.abs();
    if (a >= 1000000) return '${(v/1000000).toStringAsFixed(2)}M';
    if (a >= 1000)    return '${(v/1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
  static String _s(double v) {
    final a = v.abs();
    if (a >= 1000000) return '${(v/1000000).toStringAsFixed(1)}M';
    if (a >= 1000)    return '${(v/1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
    textTheme: GoogleFonts.cairoTextTheme(),
    scaffoldBackgroundColor: C.bg,
    appBarTheme: const AppBarTheme(
      elevation: 0, centerTitle: true,
      backgroundColor: Colors.transparent, foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: C.primary,
      unselectedItemColor: Color(0xFF9E9E9E),
      type: BottomNavigationBarType.fixed, elevation: 16,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: C.primary, foregroundColor: Colors.white, elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.unpaid)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: C.primary, foregroundColor: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}
