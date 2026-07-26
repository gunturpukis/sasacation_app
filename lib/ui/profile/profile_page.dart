// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sasacation/core/apptheme.dart';
// import 'package:sasacation/data/repo/notification_repository.dart';
// import 'package:sasacation/route/approuter.dart';
// import 'package:sasacation/viewmodel/auth/auth_bloc.dart';
// import 'package:sasacation/viewmodel/booking/booking_bloc.dart';
 
// /// ProfileScreen — restyle mengikuti mockup `my_profile_trips`.
// ///
// /// CATATAN JUJUR soal apa yang saya ambil dan apa yang saya skip dari mockup:
// /// - "X Trips Completed" DIAMBIL dan dibuat REAL — dihitung dari
// ///   BookingBloc (booking dengan status completed), bukan angka hardcode.
// ///   Saya tambahkan `BookingListRequested` di initState supaya datanya ada.
// /// - "Gold Member" (badge tier loyalty) DISKIP TOTAL — tidak ada sistem
// ///   membership/tier apa pun di backend. Menampilkan itu berarti mengarang
// ///   status yang tidak dimiliki user.
// /// - Preview "Upcoming Trips" dengan status "Action Required" di mockup
// ///   DISKIP — BookingModel cuma punya status confirmed/completed/cancelled,
// ///   tidak ada konsep "Action Required". Menu "Booking History" tetap ada
// ///   dan mengarah ke MyBookingsScreen yang sudah punya data booking lengkap
// ///   apa adanya, bukan diduplikasi di sini dengan data yang disederhanakan.
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
 
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
 
// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<AuthBloc>().add(AuthProfileRequested());
//     context.read<BookingBloc>().add(BookingListRequested());
//   }
 
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.surface,
//       appBar: AppBar(title: const Text('Profile'), centerTitle: true),
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthUnauthenticated) {
//             context.go(AppRouter.login);
//           }
//         },
//         builder: (context, state) {
//           if (state is AuthLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
 
//           final user = state is AuthAuthenticated ? state.user : null;
 
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: AppTheme.primary.withOpacity(0.1),
//                     border: Border.all(color: AppTheme.primaryContainer, width: 3),
//                   ),
//                   child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(user?.name ?? 'Guest', style: Theme.of(context).textTheme.headlineMedium),
//                 const SizedBox(height: 4),
//                 Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
 
//                 // Trip count REAL dari BookingBloc — bukan angka mockup
//                 BlocBuilder<BookingBloc, BookingState>(
//                   builder: (context, bookingState) {
//                     final completedCount = bookingState is BookingListLoaded
//                         ? bookingState.bookings.where((b) => b.isCompleted).length
//                         : null;
//                     if (completedCount == null) return const SizedBox.shrink();
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: AppTheme.surfaceContainerLow,
//                           borderRadius: BorderRadius.circular(AppTheme.radiusFull),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.stars_rounded, size: 15, color: AppTheme.secondary),
//                             const SizedBox(width: 6),
//                             Text('$completedCount Trips Completed',
//                                 style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
 
//                 if (user?.isAdmin == true) ...[
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primaryContainer,
//                       borderRadius: BorderRadius.circular(AppTheme.radiusFull),
//                     ),
//                     child: const Text('Admin',
//                         style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//                 const SizedBox(height: 24),
 
//                 Container(
//                   decoration: BoxDecoration(
//                     color: AppTheme.surfaceContainerLowest,
//                     borderRadius: BorderRadius.circular(AppTheme.radiusLg),
//                     boxShadow: AppTheme.softCardShadow,
//                   ),
//                   child: Column(
//                     children: [
//                       _buildMenuItem(
//                           icon: Icons.person_outline,
//                           title: 'Personal Information',
//                           onTap: () {}),
//                       _divider(),
//                       _buildMenuItem(
//                         icon: Icons.confirmation_number_outlined,
//                         title: 'My Bookings',
//                         onTap: () => context.push(AppRouter.myBookings),
//                       ),
//                       _divider(),
//                       _buildMenuItem(
//                           icon: Icons.favorite_border, title: 'Saved Places', onTap: () {}),
//                       _divider(),
//                       _buildMenuItem(
//                           icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
//                       _divider(),
//                       _buildMenuItem(
//                         icon: Icons.notifications_active_outlined,
//                         title: 'Test Push Notification',
//                         onTap: () => _sendTestNotification(context),
//                       ),
//                       _divider(),
//                       _buildMenuItem(
//                           icon: Icons.help_outline, title: 'Help Center', onTap: () {}),
//                       _divider(),
//                       _buildMenuItem(
//                         icon: Icons.logout,
//                         title: 'Sign Out',
//                         textColor: AppTheme.error,
//                         onTap: () => _showLogoutDialog(context),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
 
//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     Color? textColor,
//   }) {
//     return ListTile(
//       leading: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: (textColor ?? AppTheme.primary).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(AppTheme.radiusMd),
//         ),
//         child: Icon(icon, color: textColor ?? AppTheme.primary, size: 18),
//       ),
//       title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
//       trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.outline),
//       onTap: onTap,
//     );
//   }
 
//   Widget _divider() => Divider(height: 0, thickness: 0.5, color: AppTheme.outlineVariant.withOpacity(0.4));
 
//   /// Memicu push notification test ke device ini sendiri, lewat FCM token
//   /// yang sudah teregistrasi ke backend saat login. Berguna untuk QA
//   /// verifikasi setup Firebase tanpa perlu tool eksternal.
//   Future<void> _sendTestNotification(BuildContext context) async {
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.showSnackBar(const SnackBar(content: Text('Mengirim test notification...')));
 
//     final result = await NotificationRepository().sendTestNotification();
 
//     messenger.showSnackBar(SnackBar(
//       backgroundColor: result['success'] == true ? AppTheme.successColor : AppTheme.error,
//       content: Text(result['message'] ?? 'Selesai'),
//     ));
//   }
 
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Yakin ingin keluar dari akun?'),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSheet)),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               context.read<AuthBloc>().add(AuthLogoutRequested());
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/repo/notification_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';
import 'package:sasacation/viewmodel/booking/booking_bloc.dart';
 
/// ProfileScreen — restyle mengikuti mockup `my_profile_trips`.
///
/// CATATAN JUJUR soal apa yang saya ambil dan apa yang saya skip dari mockup:
/// - "X Trips Completed" DIAMBIL dan dibuat REAL — dihitung dari
///   BookingBloc (booking dengan status completed), bukan angka hardcode.
///   Saya tambahkan `BookingListRequested` di initState supaya datanya ada.
/// - "Gold Member" (badge tier loyalty) DISKIP TOTAL — tidak ada sistem
///   membership/tier apa pun di backend. Menampilkan itu berarti mengarang
///   status yang tidak dimiliki user.
/// - Preview "Upcoming Trips" dengan status "Action Required" di mockup
///   DISKIP — BookingModel cuma punya status confirmed/completed/cancelled,
///   tidak ada konsep "Action Required". Menu "Booking History" tetap ada
///   dan mengarah ke MyBookingsScreen yang sudah punya data booking lengkap
///   apa adanya, bukan diduplikasi di sini dengan data yang disederhanakan.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
 
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
 
class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthProfileRequested());
    context.read<BookingBloc>().add(BookingListRequested());
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
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
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withOpacity(0.1),
                    border: Border.all(color: AppTheme.primaryContainer, width: 3),
                  ),
                  child: const Icon(Icons.person, size: 50, color: AppTheme.primary),
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? 'Guest', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
 
                // Trip count REAL dari BookingBloc — bukan angka mockup
                BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, bookingState) {
                    final completedCount = bookingState is BookingListLoaded
                        ? bookingState.bookings.where((b) => b.isCompleted).length
                        : null;
                    if (completedCount == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, size: 15, color: AppTheme.secondary),
                            const SizedBox(width: 6),
                            Text('$completedCount Trips Completed',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
 
                if (user?.isAdmin == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Text('Admin',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 24),
 
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: AppTheme.softCardShadow,
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          onTap: () {}),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'My Bookings',
                        onTap: () => context.push(AppRouter.myBookings),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'Payment History',
                        onTap: () => context.push(AppRouter.paymentHistory),
                      ),
                      _divider(),
                      _buildMenuItem(
                          icon: Icons.favorite_border, title: 'Saved Places', onTap: () {}),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.eco_outlined,
                        title: 'Komitmen Sasacation',
                        onTap: () => context.push(AppRouter.sustainability),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () => context.push(AppRouter.settings),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () => context.push(AppRouter.notifications),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.notifications_active_outlined,
                        title: 'Test Push Notification',
                        onTap: () => _sendTestNotification(context),
                      ),
                      _divider(),
                      _buildMenuItem(
                          icon: Icons.help_outline, title: 'Help Center', onTap: () {}),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        textColor: AppTheme.error,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
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
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (textColor ?? AppTheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Icon(icon, color: textColor ?? AppTheme.primary, size: 18),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.outline),
      onTap: onTap,
    );
  }
 
  Widget _divider() => Divider(height: 0, thickness: 0.5, color: AppTheme.outlineVariant.withOpacity(0.4));
 
  /// Memicu push notification test ke device ini sendiri, lewat FCM token
  /// yang sudah teregistrasi ke backend saat login. Berguna untuk QA
  /// verifikasi setup Firebase tanpa perlu tool eksternal.
  Future<void> _sendTestNotification(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Mengirim test notification...')));
 
    final result = await NotificationRepository().sendTestNotification();
 
    messenger.showSnackBar(SnackBar(
      backgroundColor: result['success'] == true ? AppTheme.successColor : AppTheme.error,
      content: Text(result['message'] ?? 'Selesai'),
    ));
  }
 
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSheet)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
