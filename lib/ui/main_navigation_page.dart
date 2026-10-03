import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/ui/booking/booking_page.dart';
import 'package:sasacation/ui/explore/explore_page.dart';
import 'package:sasacation/ui/home/home_page.dart';
import 'package:sasacation/ui/profile/profile_page.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';
 
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
 
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}
 
class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
 
  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigateToTab: _onTabTapped),
      const ExploreScreen(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];
  }

  /// Tab Bookings (2) & Profile (3) butuh akun. Tamu yang mengetuknya
  /// mendapat prompt login (pola OTA) alih-alih error API mentah — tanpa
  /// ini, gate di level route bisa dilewati lewat tab karena tab-tab ini
  /// hidup di dalam `/home` yang guest-accessible.
  void _onTabTapped(int index) {
    final isLoggedIn =
        context.read<AuthBloc>().state is AuthAuthenticated;
    if (!isLoggedIn && (index == 2 || index == 3)) {
      _showLoginGate(context);
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showLoginGate(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusSheet)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock_outline,
                size: 44, color: AppTheme.primary),
            const SizedBox(height: 12),
            Text(l10n.auth_loginGateTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              l10n.auth_loginGateMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.push(AppRouter.login);
                },
                child: Text(l10n.auth_loginGateAction),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(l10n.auth_loginGateContinueAsGuest),
            ),
          ],
        ),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: _screens[_currentIndex],
      // ─── AI FAB — dibuat lebih menonjol sesuai semangat "Sasa AI" dari
      // mockup (di sana AI dapat slot tab sendiri; di sini tetap FAB karena
      // Explore perlu tetap gampang diakses — lihat catatan di atas class).
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAiMenu(context),
          backgroundColor: AppTheme.primaryContainer,
          tooltip: l10n.auth_aiTooltip,
          child: const Icon(Icons.auto_awesome, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppTheme.surfaceContainerLowest,
        elevation: 10,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.outline,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.auth_navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              activeIcon: const Icon(Icons.explore),
              label: l10n.auth_navExplore,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark_border_outlined),
              activeIcon: const Icon(Icons.bookmark),
              label: l10n.auth_navBookings,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l10n.auth_navProfile,
            ),
          ],
        ),
      ),
    );
  }
 
  void _showAiMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome,
                      color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.auth_aiMenuTitle, style: Theme.of(context).textTheme.titleLarge),
                    Text(l10n.auth_aiMenuSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _AiMenuItem(
              icon: Icons.chat_bubble_outline,
              color: const Color(0xFF00A896),
              title: l10n.auth_aiAskSasa,
              subtitle: l10n.auth_aiAskSasaSubtitle,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.aiChat);
              },
            ),
            const SizedBox(height: 12),
            _AiMenuItem(
              icon: Icons.auto_awesome,
              color: const Color(0xFF4299E1),
              title: l10n.auth_aiSmartSearch,
              subtitle: l10n.auth_aiSmartSearchSubtitle,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.smartSearch);
              },
            ),
            const SizedBox(height: 12),
            _AiMenuItem(
              icon: Icons.map_outlined,
              color: const Color(0xFF48BB78),
              title: l10n.auth_aiTripPlanner,
              subtitle: l10n.auth_aiTripPlannerSubtitle,
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.tripPlanner);
              },
            ),
          ],
        ),
      ),
    );
  }
}
 
class _AiMenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
 
  const _AiMenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppTheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}