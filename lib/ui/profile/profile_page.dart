import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/repo/notification_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';

/// View: ProfileScreen
/// Reads user data from AuthBloc (ViewModel).
/// Dispatches AuthLogoutRequested on logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh profile dari server
    context.read<AuthBloc>().add(AuthProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppRouter.login);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state is AuthAuthenticated ? state.user : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                  ),
                  child: const Icon(Icons.person,
                      size: 50, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Guest',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? '',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600)),
                if (user?.isAdmin == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Admin',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 24),

                // Menu
                Card(
                  child: Column(
                    children: [
                      _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          onTap: () {}),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: 'Booking History',
                        onTap: () => context.push(AppRouter.myBookings),
                      ),
                      _divider(),
                      _buildMenuItem(
                          icon: Icons.favorite_border,
                          title: 'Wishlist',
                          onTap: () {}),
                      _divider(),
                      _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {}),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.notifications_active_outlined,
                        title: 'Test Push Notification',
                        onTap: () => _sendTestNotification(context),
                      ),
                      _divider(),
                      _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () {}),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        textColor: Colors.red,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Version 1.0.0',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _divider() =>
      Divider(height: 0, thickness: 0.5, color: Colors.grey.shade200);

  /// Memicu push notification test ke device ini sendiri, lewat FCM token
  /// yang sudah teregistrasi ke backend saat login. Berguna untuk QA
  /// verifikasi setup Firebase tanpa perlu tool eksternal.
  Future<void> _sendTestNotification(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Mengirim test notification...')));

    final result = await NotificationRepository().sendTestNotification();

    messenger.showSnackBar(SnackBar(
      backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      content: Text(result['message'] ?? 'Selesai'),
    ));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Dispatch event ke AuthBloc (ViewModel)
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
