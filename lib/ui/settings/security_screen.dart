import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true
            ? 'Password berhasil diubah'
            : result['message'] ?? 'Gagal mengubah password'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email akun tidak tersedia. Silakan login ulang.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    setState(() => _sendingReset = true);
    final result = await _authRepo.sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _sendingReset = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true
            ? 'Email reset terkirim ke $email'
            : result['message'] ?? 'Gagal mengirim email reset'),
        backgroundColor: result['success'] == true
            ? AppTheme.successColor
            : AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar:
          AppBar(title: const Text('Security & Password'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ubah Password',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Password baru minimal 8 karakter (aturan server).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password saat ini',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Password saat ini wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password baru (min. 8 karakter)',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Password baru wajib diisi';
                  }
                  if (v.length < 8) {
                    return 'Password minimal 8 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Konfirmasi password baru',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (v) => v != _newCtrl.text
                    ? 'Konfirmasi tidak sama'
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
                      : const Text('Ubah Password'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _sendingReset ? null : _sendReset,
                  child: Text(_sendingReset
                      ? 'Mengirim...'
                      : 'Kirim email reset password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
