
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/core/notification_service.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';
 
/// SettingsScreen — layar baru, sebelumnya TIDAK ADA sama sekali.
///
/// PRINSIP yang saya pegang di sini: SETIAP toggle/opsi yang ditampilkan
/// HARUS benar-benar melakukan sesuatu. Saya TIDAK membuat toggle
/// "Language"/"Dark Mode"/"Currency" dekoratif yang keliatan bisa diklik
/// tapi tidak mengubah apa-apa — itu UI yang menipu.
///
/// Yang REAL di sini:
/// - Push Notifications: toggle sungguhan, memanggil
///   NotificationService.instance.registerCurrentToken() / unregisterToken()
///   yang SUDAH ADA di codebase (dipakai saat login), cuma belum pernah
///   diekspos sebagai kontrol manual ke user.
/// - Logout: reuse AuthBloc yang sama dengan di Profile.
///
/// Yang SENGAJA tidak ada: Language switcher (app cuma pakai 1 bahasa
/// campuran ID/EN hardcode, tidak ada sistem l10n/.arb), Dark Mode (tidak
/// ada ThemeMode.dark terpisah di AppTheme saat ini), Currency switcher
/// (semua harga di backend disimpan dalam USD, tidak ada konversi).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
 
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
 
class _SettingsScreenState extends State<SettingsScreen> {
  static const _prefKey = 'push_notifications_enabled';
  bool _pushEnabled = true;
  bool _loading = true;
 
  @override
  void initState() {
    super.initState();
    _loadPref();
  }
 
  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool(_prefKey) ?? true;
      _loading = false;
    });
  }
 
  Future<void> _togglePush(bool value) async {
    setState(() => _pushEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
 
    if (value) {
      await NotificationService.instance.registerCurrentToken();
    } else {
      await NotificationService.instance.unregisterToken();
    }
 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Push notification diaktifkan'
              : 'Push notification dimatikan — kamu tidak akan menerima notifikasi booking di device ini'),
        ),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionLabel('NOTIFICATIONS'),
                _card([
                  SwitchListTile(
                    value: _pushEnabled,
                    onChanged: _togglePush,
                    activeThumbColor: AppTheme.primaryContainer,
                    title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Update booking, konfirmasi pembayaran, dan info penting lainnya',
                        style: TextStyle(fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionLabel('ACCOUNT'),
                _card([
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                    title: const Text('Riwayat Notifikasi'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push(AppRouter.notifications),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.error),
                    title: const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
                    onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionLabel('ABOUT'),
                _card([
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: AppTheme.primary),
                    title: Text('App Version'),
                    trailing: Text('1.0.0', style: TextStyle(color: AppTheme.outline)),
                  ),
                ]),
              ],
            ),
    );
  }
 
  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      );
 
  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.softCardShadow,
        ),
        child: Column(children: children),
      );
}
 