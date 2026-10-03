import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// S1.2: locale aplikasi (domestic-first: Indonesia primer).
///
/// Kode bahasa: 'id' | 'en' (sama persis dengan kolom `language` server).
/// null = ikuti sistem (fallback id bila sistem di luar id/en).
class AppLocale {
  static const prefKey = 'language';
  static final locale = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(prefKey);
    locale.value = _toLocale(code);
  }

  static Future<void> set(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, code);
    locale.value = _toLocale(code);
  }

  static Locale? _toLocale(String? code) => switch (code) {
        'en' => const Locale('en', 'US'),
        'id' => const Locale('id', 'ID'),
        _ => null,
      };

  /// Dipakai MaterialApp.localeResolutionCallback: di luar id/en,
  /// jatuhkan ke id_ID (domestic-first).
  static Locale resolve(Locale? device) {
    if (device != null) {
      if (device.languageCode == 'id') return const Locale('id', 'ID');
      if (device.languageCode == 'en') return const Locale('en', 'US');
    }
    return const Locale('id', 'ID');
  }
}
