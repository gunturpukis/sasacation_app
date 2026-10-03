import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/data/repo/auth_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';

/// View: LoginScreen
/// Email/Password + Google + Apple Sign In (MVVM via AuthBloc)
class LoginScreen extends StatefulWidget {
  /// Jika diisi (mis. saat login gate muncul di titik checkout), user akan
  /// diarahkan kembali ke rute ini setelah berhasil login, bukan ke Home.
  final String? redirectRoute;
  final Object? redirectExtra;

  const LoginScreen({super.key, this.redirectRoute, this.redirectExtra});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isRegisterMode = false;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (widget.redirectRoute != null) {
            context.go(widget.redirectRoute!, extra: widget.redirectExtra);
          } else {
            context.go(AppRouter.home);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Back to onboarding
                IconButton(
                  onPressed: () => context.go(AppRouter.onboarding),
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  _isRegisterMode ? l10n.auth_loginCreateAccountTitle : l10n.auth_loginWelcomeTitle,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  _isRegisterMode
                      ? l10n.auth_loginRegisterSubtitle
                      : l10n.auth_loginSubtitle,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 28),

                // Error banner
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthError) {
                      return _ErrorBanner(message: state.message);
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isRegisterMode) ...[
                        _TextField(
                          controller: _nameCtrl,
                          label: l10n.auth_loginFullNameLabel,
                          icon: Icons.person_outline,
                          validator: (v) =>
                              v == null || v.isEmpty ? l10n.auth_loginNameRequired : null,
                        ),
                        const SizedBox(height: 14),
                      ],
                      _TextField(
                        controller: _emailCtrl,
                        label: l10n.auth_loginEmailLabel,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.auth_loginEmailRequired;
                          if (!v.contains('@')) return l10n.auth_loginEmailInvalid;
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _TextField(
                        controller: _passCtrl,
                        label: l10n.auth_loginPasswordLabel,
                        icon: Icons.lock_outline,
                        obscureText: _obscure,
                        suffix: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.auth_loginPasswordRequired;
                          if (_isRegisterMode && v.length < 6) {
                            return l10n.auth_loginPasswordTooShort;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                if (!_isRegisterMode) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _handleForgotPassword(context),
                      child: Text(l10n.auth_loginForgotPassword),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Primary button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isRegisterMode ? l10n.auth_loginRegisterButton : l10n.auth_loginButton,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Divider
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.auth_loginOrDivider, style: TextStyle(color: Colors.grey.shade500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ]),
                const SizedBox(height: 20),

                // Google Sign In
                _SocialButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(AuthGoogleSignInRequested()),
                  icon: _GoogleIcon(),
                  label: l10n.auth_loginContinueWithGoogle,
                ),
                const SizedBox(height: 12),

                // Apple Sign In (iOS only)
                if (Platform.isIOS) ...[
                  _SocialButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(AuthAppleSignInRequested()),
                    icon: const Icon(Icons.apple, size: 22, color: Colors.black),
                    label: l10n.auth_loginContinueWithApple,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                ],

                // Toggle register / login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isRegisterMode
                          ? l10n.auth_loginAlreadyHaveAccount
                          : l10n.auth_loginNoAccountYet,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _isRegisterMode = !_isRegisterMode),
                      child: Text(
                        _isRegisterMode ? l10n.auth_loginButton : l10n.auth_loginRegisterButton,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Guest mode: jalan keluar sebagai tamu — penting karena
                // layar ini juga dipakai sebagai login gate dari route yang
                // butuh akun. Tamu yang memilih ini kembali browsing bebas.
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.go(AppRouter.home),
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: Text(l10n.auth_loginContinueAsGuest),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reset password REAL via Firebase ke email yang diketik di form.
  Future<void> _handleForgotPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.auth_loginFillEmailFirst),
        ),
      );
      return;
    }
    final send = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.auth_loginResetPasswordTitle),
        content: Text(l10n.auth_loginResetPasswordConfirm(email)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.common_cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.auth_loginSend)),
        ],
      ),
    );
    if (send != true || !context.mounted) return;
    final result = await AuthRepository().sendPasswordReset(email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true
            ? l10n.auth_loginResetEmailSent(email)
            : (result['message'] as String? ?? l10n.auth_loginResetEmailFailed)),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegisterMode) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ));
    } else {
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ));
    }
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;
    final fg = textColor ?? Colors.black87;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(vertical: 13),
          side: BorderSide(color: backgroundColor != null ? Colors.transparent : Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 15, color: fg, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    final paint = Paint()..style = PaintingStyle.fill;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final angles = [0.0, 90.0, 180.0, 270.0];
    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        (angles[i] - 45) * 3.14159 / 180,
        90 * 3.14159 / 180,
        true,
        paint,
      );
    }
    paint.color = Colors.white;
    canvas.drawCircle(c, r * 0.55, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
