import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/utils/money.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    // S1.1: muat kurs di background (gagal = tetap mode USD, non-blocking).
    unawaited(ForexService.refresh());
    if (!mounted) return;
    // FIX: baca SharedPreferences — tidak hardcode
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;
    if (!hasSeenOnboarding) {
      context.go(AppRouter.onboarding);
    } else {
      // Guest mode: tamu tanpa akun langsung ke home (browsing bebas).
      // Login baru diminta di titik yang butuh akun (checkout, tab
      // Bookings/Profile) lewat login gate kontekstual.
      context.go(AppRouter.home);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), AppTheme.primaryColor, Color(0xFF00A896)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.travel_explore, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.auth_splashAppName,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(l10n.auth_splashTagline,
                      style: const TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
