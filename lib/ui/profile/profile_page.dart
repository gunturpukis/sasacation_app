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
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/data/repo/notification_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:sasacation/utils/money.dart';
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
/// - Preview "Upcoming Trips" DIAMBIL dan dibuat REAL — 2 booking confirmed
///   terdekat (diurut check-in) dengan foto, badge hitung mundur, harga, dan
///   tombol ke MyBookings. Status "Action Required" di mockup tidak ada
///   padanannya di BookingModel (cuma confirmed/completed/cancelled), jadi
///   hanya CONFIRMED yang ditampilkan apa adanya; section disembunyikan
///   kalau tidak ada trip mendatang (tidak mengarang data).
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(l10n.me_profileTitle), centerTitle: true),
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
                Text(user?.name ?? l10n.me_guestName, style: Theme.of(context).textTheme.headlineMedium),
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
                            Text(l10n.me_tripsCompleted(completedCount),
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
                    child: Text(l10n.me_adminBadge,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(height: 24),

                // Preview "Upcoming Trips" mengikuti mockup — datanya REAL dari
                // BookingBloc (booking confirmed yang belum checkout). Status
                // "Action Required" di mockup tidak ada padanannya di
                // BookingModel, jadi hanya CONFIRMED yang ditampilkan apa adanya.
                BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, bookingState) {
                    if (bookingState is! BookingListLoaded) {
                      return const SizedBox.shrink();
                    }
                    final now = DateTime.now();
                    // F1: booking pending ikut tampil dengan badge
                    // "Action Required" seperti mockup — penyelesaiannya
                    // lewat tombol Complete Booking di My Bookings.
                    final upcoming = bookingState.bookings
                        .where((b) =>
                            (b.isConfirmed || b.isPending) &&
                            b.checkOut.isAfter(now))
                        .toList()
                      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));
                    if (upcoming.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.me_upcomingTrips,
                                style: Theme.of(context).textTheme.titleLarge),
                            TextButton(
                              onPressed: () =>
                                  context.push(AppRouter.myBookings),
                              child: Text(l10n.me_seeAll,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...upcoming
                            .take(2)
                            .map((b) => _UpcomingTripCard(booking: b)),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
 
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
                        title: l10n.me_menuPersonalInfo,
                        onTap: () =>
                            context.push(AppRouter.personalInfo),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.tune_outlined,
                        title: Localizations.localeOf(context).languageCode == 'en'
                            ? 'Travel Profile'
                            : 'Profil Travel',
                        onTap: () => context.push(AppRouter.travelProfile),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.confirmation_number_outlined,
                        title: l10n.me_menuMyBookings,
                        onTap: () => context.push(AppRouter.myBookings),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.me_menuPaymentHistory,
                        onTap: () => context.push(AppRouter.paymentHistory),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.favorite_border,
                        title: l10n.me_menuSavedPlaces,
                        onTap: () => context.push(AppRouter.wishlist),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.group_outlined,
                        title: l10n.me_menuMyGroups,
                        onTap: () => context.push(AppRouter.groups),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.task_alt_outlined,
                        title: l10n.me_menuTravelTasks,
                        onTap: () => context.push(AppRouter.tasks),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.eco_outlined,
                        title: l10n.me_menuSustainability,
                        onTap: () => context.push(AppRouter.sustainability),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: l10n.me_menuSettings,
                        onTap: () => context.push(AppRouter.settings),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: l10n.me_menuNotifications,
                        onTap: () => context.push(AppRouter.notifications),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.notifications_active_outlined,
                        title: l10n.me_menuTestPush,
                        onTap: () => _sendTestNotification(context),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: l10n.me_menuHelpCenter,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.me_helpCenterSoon),
                          ),
                        ),
                      ),
                      _divider(),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: l10n.common_signOut,
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
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.me_sendingTestNotification)));
 
    final result = await NotificationRepository().sendTestNotification();
 
    messenger.showSnackBar(SnackBar(
      backgroundColor: result['success'] == true ? AppTheme.successColor : AppTheme.error,
      content: Text(result['message'] ?? l10n.me_fallbackDone),
    ));
  }
 
  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.me_logoutTitle),
        content: Text(l10n.me_logoutConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSheet)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.common_cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(l10n.me_logoutTitle),
          ),
        ],
      ),
    );
  }
}

/// Kartu preview trip mendatang — mengikuti mockup `my_profile_trips`
/// (foto, badge status, harga, tombol aksi). Maks 2 kartu, selebihnya lewat
/// "Lihat semua" ke MyBookingsScreen.
class _UpcomingTripCard extends StatelessWidget {
  final BookingModel booking;
  const _UpcomingTripCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = DateFormat('d MMM yyyy');
    final daysLeft = booking.checkIn.difference(DateTime.now()).inDays;
    final isPending = booking.isPending;
    final badgeLabel = isPending
        ? l10n.me_actionRequired
        : daysLeft > 0
            ? l10n.me_daysLeft(daysLeft)
            : l10n.me_confirmedBadge;
    final badgeColor = isPending
        ? AppTheme.secondaryContainer
        : AppTheme.primaryContainer;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusCard)),
                child: Image.network(
                  booking.hotelImage,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: AppTheme.surfaceContainerHigh,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppTheme.outline),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(badgeLabel,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.hotelName,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            '${fmt.format(booking.checkIn)} – ${fmt.format(booking.checkOut)} • ${l10n.me_nightsCount(booking.nights)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    MoneyText(booking.totalPrice,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push(AppRouter.myBookings),
                    child: Text(l10n.me_actionViewBooking),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
