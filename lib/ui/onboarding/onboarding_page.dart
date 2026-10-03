import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _onboardingData(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
    OnboardingData(
      title: l10n.auth_onboardingTitleExplore,
      description: l10n.auth_onboardingDescExplore,
      icon: Icons.explore,
      color: AppTheme.primaryColor,
    ),
    OnboardingData(
      title: l10n.auth_onboardingTitleBooking,
      description: l10n.auth_onboardingDescBooking,
      icon: Icons.book_online,
      color: AppTheme.secondaryColor,
    ),
    OnboardingData(
      title: l10n.auth_onboardingTitleCulinary,
      description: l10n.auth_onboardingDescCulinary,
      icon: Icons.restaurant,
      color: AppTheme.accentColor,
    ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboardingData = _onboardingData(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingPage(data: onboardingData[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol Next/Get Started
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentPage == onboardingData.length - 1) {
                        await _saveOnboardingStatus();
                        if (mounted) {
                          // Guest mode: langsung ke home, login menyusul
                          // saat dibutuhkan (checkout/tab personal).
                          context.go(AppRouter.home);
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? l10n.auth_onboardingExploreAsGuest
                          : l10n.auth_onboardingNext,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Tombol Skip (hanya muncul jika belum di halaman terakhir)
                if (_currentPage != onboardingData.length - 1)
                  TextButton(
                    onPressed: () async {
                      // Simpan status bahwa user skip onboarding
                      await _saveOnboardingStatus();
                      // Guest mode: langsung ke home sebagai tamu
                      if (mounted) {
                        context.go(AppRouter.home);
                      }
                    },
                    child: Text(
                      l10n.auth_onboardingSkip,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simpan status onboarding ke SharedPreferences
  Future<void> _saveOnboardingStatus() async {
    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    // Untuk sementara pakai delay simulasi
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}