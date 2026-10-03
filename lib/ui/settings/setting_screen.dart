
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sasacation/core/app_locale.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/core/notification_service.dart';
import 'package:sasacation/data/repo/settings_repository.dart';
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
/// - Personal Information: edit nama via PUT /auth/profile (AuthBloc).
/// - Security & Password: ubah password + email reset via Firebase Auth.
/// - Push Notifications: toggle sungguhan, memanggil
///   NotificationService.instance.registerCurrentToken() / unregisterToken()
///   yang SUDAH ADA di codebase (dipakai saat login), cuma belum pernah
///   diekspos sebagai kontrol manual ke user.
/// - Logout: reuse AuthBloc yang sama dengan di Profile.
///
/// S1.2: Bahasa kini REAL via l10n .arb (id primer, en) + tersimpan di
/// server + diterapkan langsung tanpa restart.
///
/// Yang SENGAJA tidak ada: Travel Preferences visual (butuh backend
/// preferensi), Dark Mode (tidak ada ThemeMode.dark terpisah di AppTheme
/// saat ini). Mata uang mengikuti kurs server (lihat utils/money.dart),
/// bukan switch manual.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
 
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
 
class _SettingsScreenState extends State<SettingsScreen> {
  static const _prefKey = 'push_notifications_enabled';
  final _settingsRepo = SettingsRepository();
  bool _pushEnabled = true;
  bool _aiPersonalization = true;
  String _language = 'id';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  /// Sumber kebenaran: server (F5). Cache lokal hanya fallback bila offline
  /// saat membuka layar — agar toggle tidak tampil salah.
  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final localPush = prefs.getBool(_prefKey) ?? true;
    final localAi =
        prefs.getBool(SettingsRepository.localAiKey) ?? true;
    final remote = await _settingsRepo.getSettings();
    if (!mounted) return;
    setState(() {
      _pushEnabled = (remote?['push_enabled'] as bool?) ?? localPush;
      _aiPersonalization =
          (remote?['ai_personalization'] as bool?) ?? localAi;
      _language = (remote?['language'] as String?) ??
          prefs.getString(AppLocale.prefKey) ??
          'id';
      _loading = false;
    });
  }

  /// S1.2: ganti bahasa — tersimpan di server + diterapkan langsung.
  Future<void> _setLanguage(String code) async {
    final l10n = AppLocalizations.of(context);
    final result = await _settingsRepo.updateSettings(language: code);
    if (!mounted) return;
    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? l10n.me_saveFailed),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    await AppLocale.set(code);
    if (!mounted) return;
    setState(() => _language = code);
  }

  Future<void> _togglePush(bool value) async {
    final l10n = AppLocalizations.of(context);
    final result =
        await _settingsRepo.updateSettings(pushEnabled: value);
    if (!mounted) return;
    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message'] ?? l10n.me_saveFailed),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
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
              ? l10n.me_pushEnabledMsg
              : l10n.me_pushDisabledMsg),
        ),
      );
    }
  }

  Future<void> _toggleAi(bool value) async {
    final l10n = AppLocalizations.of(context);
    final result =
        await _settingsRepo.updateSettings(aiPersonalization: value);
    if (!mounted) return;
    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message'] ?? l10n.me_saveFailed),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    setState(() => _aiPersonalization = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? l10n.me_aiEnabledMsg
              : l10n.me_aiDisabledMsg),
        ),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(l10n.me_settingsTitle), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionLabel(l10n.me_sectionAccountMgmt),
                _card([
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: AppTheme.primary),
                    title: Text(l10n.me_menuPersonalInfo,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.me_personalInfoSubtitle,
                        style: const TextStyle(fontSize: 12)),
                    trailing:
                        const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push(AppRouter.personalInfo),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined,
                        color: AppTheme.primary),
                    title: Text(l10n.me_securityTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.me_securitySubtitle,
                        style: const TextStyle(fontSize: 12)),
                    trailing:
                        const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push(AppRouter.security),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionLabel(l10n.me_sectionNotifications),
                _card([
                  SwitchListTile(
                    value: _pushEnabled,
                    onChanged: _togglePush,
                    activeThumbColor: AppTheme.primaryContainer,
                    title: Text(l10n.me_pushTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(l10n.me_pushSubtitle,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 24),
                // S1.2: pilihan bahasa kini REAL — l10n .arb (id primer,
                // en fallback) + tersimpan di server + diterapkan langsung.
                _sectionLabel(l10n.me_sectionGeneral),
                _card([
                  ListTile(
                    leading: const Icon(Icons.language_outlined,
                        color: AppTheme.primary),
                    title: Text(l10n.me_languageTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        _language == 'id'
                            ? 'Bahasa Indonesia'
                            : 'English (US)',
                        style: const TextStyle(fontSize: 12)),
                    trailing:
                        const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showLanguageSheet(context),
                  ),
                ]),
                const SizedBox(height: 24),
                // F5: preferensi AI nyata — OFF menyembunyikan kartu AI Pick
                // di hasil pencarian (efek lokal) + tersimpan di server.
                _sectionLabel(l10n.me_sectionSasaAi),
                _card([
                  SwitchListTile(
                    value: _aiPersonalization,
                    onChanged: _toggleAi,
                    activeThumbColor: AppTheme.primaryContainer,
                    title: Text(l10n.me_aiTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        l10n.me_aiSubtitle,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionLabel(l10n.me_sectionAccount),
                _card([
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                    title: Text(l10n.me_notifHistory),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.push(AppRouter.notifications),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.error),
                    title: Text(l10n.common_signOut, style: const TextStyle(color: AppTheme.error)),
                    onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                  ),
                ]),
                const SizedBox(height: 24),
                _sectionLabel(l10n.me_sectionAbout),
                _card([
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppTheme.primary),
                    title: Text(l10n.me_appVersion),
                    trailing: const Text('1.0.0', style: TextStyle(color: AppTheme.outline)),
                  ),
                ]),
              ],
            ),
    );
  }
 
  void _showLanguageSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusSheet)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.me_chooseLanguage,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _languageTile('id', 'Bahasa Indonesia', l10n.me_langIdSubtitle),
            _languageTile('en', 'English (US)', l10n.me_langEnSubtitle),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(String code, String title, String subtitle) {
    final selected = _language == code;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: TextStyle(
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppTheme.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        if (!selected) _setLanguage(code);
      },
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
 