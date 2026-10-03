import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/repo/auth_repository.dart';
import 'package:sasacation/data/repo/settings_repository.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';

/// Security & Password — mengikuti mockup `settings & preferences`
/// ("Change your credentials"). Ubah password REAL via backend
/// (F5: POST /api/auth/change-password, min. 8 karakter); email reset via
/// Firebase Auth. Pesan error backend ditampilkan apa adanya.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _settingsRepo = SettingsRepository();
  final _authRepo = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _sendingReset = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final result = await _settingsRepo.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true
            ? l10n.me_passwordChanged
            : result['message'] ?? l10n.me_passwordChangeFailed),
        backgroundColor: result['success'] == true
            ? AppTheme.successColor
            : AppTheme.error,
      ),
    );
    if (result['success'] == true) {
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    }
  }

  Future<void> _sendReset() async {
    final state = context.read<AuthBloc>().state;
    final email =
        state is AuthAuthenticated ? state.user.email : null;
    if (email == null || email.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.me_emailUnavailable),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    setState(() => _sendingReset = true);
    final result = await _authRepo.sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _sendingReset = false);
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true
            ? l10n.me_resetSent(email)
            : result['message'] ?? l10n.me_resetFailed),
        backgroundColor: result['success'] == true
            ? AppTheme.successColor
            : AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar:
          AppBar(title: Text(l10n.me_securityTitle), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.me_changePassword,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                l10n.me_passwordRule,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l10n.me_currentPasswordHint,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? l10n.me_currentPasswordRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l10n.me_newPasswordHint,
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return l10n.me_newPasswordRequired;
                  }
                  if (v.length < 8) {
                    return l10n.me_passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: l10n.me_confirmPasswordHint,
                  prefixIcon: const Icon(Icons.check_circle_outline),
                ),
                validator: (v) => v != _newCtrl.text
                    ? l10n.me_confirmMismatch
                    : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _changePassword,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.me_changePassword),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _sendingReset ? null : _sendReset,
                  child: Text(_sendingReset
                      ? l10n.me_sending
                      : l10n.me_sendResetEmail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
