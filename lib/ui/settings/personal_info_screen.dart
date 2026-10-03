import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';

/// Personal Information — mengikuti mockup `settings & preferences`
/// ("Update your details"). REAL: nama disimpan lewat
/// `PUT /auth/profile` (AuthRepository.updateProfile) via AuthBloc, email
/// read-only karena terikat identitas Firebase dan tidak bisa diubah dari
/// endpoint profil.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final initialName =
        state is AuthAuthenticated ? state.user.name : '';
    _nameCtrl = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        if (state is AuthProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.me_profileUpdated)),
          );
          // Kembalikan state global ke AuthAuthenticated agar layar lain
          // (yang hanya membaca AuthAuthenticated) tetap menampilkan user.
          context.read<AuthBloc>().add(AuthProfileRequested());
          context.pop();
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ),
          );
          // Kembalikan state ke AuthAuthenticated (lihat catatan di bloc).
          context.read<AuthBloc>().add(AuthProfileRequested());
        }
      },
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        final user = switch (state) {
          AuthAuthenticated(user: final u) => u,
          AuthProfileUpdated(user: final u) => u,
          _ => null,
        };
        final saving = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
              title: Text(l10n.me_menuPersonalInfo),
              centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withOpacity(0.1),
                        border: Border.all(
                            color: AppTheme.primaryContainer, width: 3),
                      ),
                      child: const Icon(Icons.person,
                          size: 44, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.me_fullNameLabel,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: l10n.me_fullNameHint,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.me_nameRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.me_emailLabel,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusButton),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined,
                            size: 20, color: AppTheme.outline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(user?.email ?? '-',
                              style:
                                  const TextStyle(fontSize: 15)),
                        ),
                        const Icon(Icons.lock_outline,
                            size: 16, color: AppTheme.outline),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.me_emailLockedNote,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () {
                              if (!_formKey.currentState!
                                  .validate()) {
                                return;
                              }
                              context.read<AuthBloc>().add(
                                  AuthProfileUpdateRequested(
                                      name: _nameCtrl.text.trim()));
                            },
                      child: saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : Text(l10n.common_save),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
