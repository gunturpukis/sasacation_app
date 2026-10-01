import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/data/model/checkout_model.dart';
import 'package:sasacation/data/model/explore_model.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/ui/ai/agent_trip_plan_result_screen.dart';
import 'package:sasacation/ui/ai/ai_chat_screen.dart';
import 'package:sasacation/ui/ai/smart_search_screen.dart';
import 'package:sasacation/ui/ai/trip_planner_screen.dart';
import 'package:sasacation/ui/explore/destination_detail_screen.dart';
import 'package:sasacation/ui/booking/booking_page.dart';
import 'package:sasacation/ui/groups/group_detail_screen.dart';
import 'package:sasacation/ui/groups/group_list_screen.dart';
import 'package:sasacation/ui/checkout/booking_confirm_screen.dart';
import 'package:sasacation/ui/checkout/checkout_screen.dart';
import 'package:sasacation/ui/hotels/adminpanel/admin_panel_page.dart';
import 'package:sasacation/ui/login/login_page.dart';
import 'package:sasacation/ui/main_navigation_page.dart';
import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
import 'package:sasacation/ui/payment/payment_history_screen.dart';
import 'package:sasacation/ui/search/search_results_page.dart';
import 'package:sasacation/ui/sustainibility/sustainibility_screen.dart';
import 'package:sasacation/viewmodel/search/hotel_search_cubit.dart';
import 'package:sasacation/ui/trip/trip_detail_screen.dart';
import 'package:sasacation/ui/trip/trip_management_screen.dart';
import 'package:sasacation/ui/wishlist/wishlist_page.dart';
import 'package:sasacation/ui/notification/notification_screen.dart';
import 'package:sasacation/ui/tasks/tasks_screen.dart';
import 'package:sasacation/ui/poll/poll_detail_screen.dart';
import 'package:sasacation/ui/settings/personal_info_screen.dart';
import 'package:sasacation/ui/settings/security_screen.dart';
import 'package:sasacation/ui/settings/setting_screen.dart';
import 'package:sasacation/ui/splash/splash_page.dart';
import 'package:sasacation/ui/onboarding/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String hotelDetail = '/hotel-detail/:id';
  static const String searchResults = '/search-results';
  static const String wishlist = '/wishlist';
  static const String myBookings = '/my-bookings';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String personalInfo = '/settings/personal-info';
  static const String security = '/settings/security';
  static const String paymentHistory = '/payment-history';
  static const String sustainability = '/sustainability';
  // Alias lama (typo) — dipertahankan agar deep-link lama tidak 404.
  static const String legacySustainability = '/sustainibility';
  static const String admin = '/admin';
  // Checkout flow
  static const String checkout = '/checkout';
  static const String bookingConfirm = '/booking-confirm';
  // AI
  static const String aiChat = '/ai-chat';
  static const String smartSearch = '/smart-search';
  static const String tripPlanner = '/trip-planner';
  static const String tripPlanResult = '/ai/trip-plan-result';
  // Explore
  static const String destinationDetail = '/destination-detail';
  // Trip Management
  static const String tripManagement = '/trip-management';
  static const String tripDetail = '/trip-detail/:id';
  // F7: voting grup
  static const String pollDetail = '/poll/:id';
  // F8: budget grup
  static const String groups = '/groups';
  static const String groupDetail = '/group/:id';
  // F10: travel tasks
  static const String tasks = '/tasks';

  static String tripDetailPath(String id) =>
      tripDetail.replaceFirst(':id', id);
  static String hotelDetailPath(String id) =>
      hotelDetail.replaceFirst(':id', id);
  static String pollDetailPath(String id) =>
      pollDetail.replaceFirst(':id', id);
  static String groupDetailPath(String id) =>
      groupDetail.replaceFirst(':id', id);

  /// Rute yang boleh diakses tanpa login (guest browsing), meniru pola OTA:
  /// pengguna bisa melihat-lihat hotel bebas, login baru wajib saat mau
  /// benar-benar memesan (checkout) atau mengakses data personal (booking,
  /// notifikasi, AI, trip).
  /// CATATAN: wishlist guest-accessible karena state-nya lokal
  /// (WishlistCubit, tanpa akun) dan toggle hati di search tidak di-gate —
  /// meng-gate halamannya saja akan membuat favorit yang disimpan tamu
  /// tidak bisa dilihat.
  /// `/hotel-detail/:id` tidak dicantumkan di sini karena
  /// `matchedLocation` berisi path konkret (`/hotel-detail/123`), bukan pola
  /// dengan parameter — pengecekannya lewat `startsWith` di `redirect`.
  static const Set<String> guestAccessible = {
    splash,
    onboarding,
    login,
    home,
    searchResults,
    wishlist,
  };
}

class Routes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRouter.splash,
    routes: [
      // ─── Core ─────────────────────────────────────────────────────────────
      GoRoute(path: AppRouter.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: AppRouter.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRouter.login,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LoginScreen(
            redirectRoute: extra?['redirectRoute'] as String?,
            redirectExtra: extra?['redirectExtra'],
          );
        },
      ),
      GoRoute(path: AppRouter.home, builder: (_, _) => const MainNavigation()),

      // ─── Hotel ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.hotelDetail,
        builder: (_, state) =>
            HotelDetailScreen(hotelId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRouter.destinationDetail,
        builder: (_, state) {
          final item = state.extra as ExploreItemModel?;
          if (item == null) {
            return const _MissingExtraScreen(message: 'Data destinasi tidak ditemukan.');
          }
          return DestinationDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: AppRouter.tripPlanResult,
        builder: (_, state) {
          final plan = state.extra as TripPlan?;
          if (plan == null) {
            return const _MissingExtraScreen(message: 'Data trip plan tidak ditemukan.');
          }
          return AgentTripPlanResultScreen(plan: plan);
        },
      ),
      GoRoute(
        path: AppRouter.searchResults,
        builder: (_, state) => BlocProvider(
          create: (_) => HotelSearchCubit(),
          child: SearchResultsScreen(
            initialQuery: state.uri.queryParameters['q'],
          ),
        ),
      ),
      GoRoute(
        path: AppRouter.wishlist,
        builder: (_, _) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRouter.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRouter.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      // Butuh akun (tidak ada di guestAccessible) — sama seperti induknya.
      GoRoute(
        path: AppRouter.personalInfo,
        builder: (_, _) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: AppRouter.security,
        builder: (_, _) => const SecurityScreen(),
      ),
      // ─── AI ────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.aiChat,
        builder: (_, _) => const AiChatScreen(),
      ),
      GoRoute(
        path: AppRouter.smartSearch,
        builder: (_, _) => const SmartSearchScreen(),
      ),
      GoRoute(
        path: AppRouter.tripPlanner,
        builder: (_, _) => const TripPlannerScreen(),
      ),
      // ─── Trip Management ───────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.tripManagement,
        builder: (_, _) => const TripManagementScreen(),
      ),
      GoRoute(
        path: AppRouter.tripDetail,
        builder: (_, state) =>
            TripDetailScreen(tripId: state.pathParameters['id']!),
      ),
      // F7: butuh akun (tidak ada di guestAccessible).
      GoRoute(
        path: AppRouter.pollDetail,
        builder: (_, state) =>
            PollDetailScreen(pollId: state.pathParameters['id']!),
      ),
      // F8: butuh akun (tidak ada di guestAccessible).
      GoRoute(
        path: AppRouter.groups,
        builder: (_, _) => const GroupListScreen(),
      ),
      GoRoute(
        path: AppRouter.groupDetail,
        builder: (_, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
      // F10: butuh akun (tidak ada di guestAccessible).
      GoRoute(
        path: AppRouter.tasks,
        builder: (_, _) => const TasksScreen(),
      ),
       GoRoute(
        path: AppRouter.paymentHistory,
        builder: (_, _) => const PaymentHistoryScreen(),
      ),
      GoRoute(
        path: AppRouter.sustainability,
        builder: (_, _) => const SustainabilityScreen(),
      ),
      // Kompatibilitas: path lama dengan typo tetap bisa dibuka.
      GoRoute(
        path: AppRouter.legacySustainability,
        builder: (_, _) => const SustainabilityScreen(),
      ),

      // ─── Booking & Checkout flow ──────────────────────────────────────────
      GoRoute(
        path: AppRouter.myBookings,
        builder: (_, _) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRouter.checkout,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>?;
          if (data == null ||
              data['hotel'] is! HotelModel ||
              data['checkIn'] is! DateTime ||
              data['checkOut'] is! DateTime ||
              data['nights'] is! int ||
              data['guestCount'] is! int) {
            return const _MissingExtraScreen(
              message: 'Data checkout tidak lengkap. Silakan mulai dari halaman hotel.',
            );
          }
          return CheckoutScreen(
            hotel: data['hotel'] as HotelModel,
            checkIn: data['checkIn'] as DateTime,
            checkOut: data['checkOut'] as DateTime,
            nights: data['nights'] as int,
            guestCount: data['guestCount'] as int,
            notes: data['notes'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRouter.bookingConfirm,
        builder: (_, state) {
          final result = state.extra as PaymentResult?;
          if (result == null) {
            return const _MissingExtraScreen(
              message: 'Data konfirmasi pembayaran tidak ditemukan.',
            );
          }
          return BookingConfirmScreen(result: result);
        },
      ),

      // ─── Admin ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.admin,
        builder: (_, _) => const AdminPanelScreen(),
      ),
    ],
 
    redirect: (context, state) async {
      final isLoggedIn = await _checkAuthStatus();
      final hasSeenOnboarding = await _checkOnboardingStatus();
      final loc = state.matchedLocation;
 
      // hotel-detail dipetakan dengan path parameter (/hotel-detail/:id), jadi
      // dicek lewat prefix, bukan exact-match seperti rute statis lainnya.
      final isGuestAccessible = AppRouter.guestAccessible.contains(loc) ||
          loc.startsWith('/hotel-detail/');
 
      if (!hasSeenOnboarding && loc != AppRouter.onboarding && loc != AppRouter.splash) {
        return AppRouter.onboarding;
      }
      // Hanya rute yang butuh akun (checkout, booking, admin, AI, dst) yang
      // di-gate. Browsing hotel & pencarian tetap bisa diakses sebagai guest.
      if (hasSeenOnboarding && !isLoggedIn && !isGuestAccessible) {
        return AppRouter.login;
      }
      if (isLoggedIn && (loc == AppRouter.login || loc == AppRouter.onboarding)) {
        return AppRouter.home;
      }
      return null;
    },
  );
 
  static Future<bool> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
 
  static Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }
}

/// Layar fallback saat route dibuka tanpa `extra` yang wajib.
/// Mencegah crash `state.extra as ...` jika user deep-link langsung.
class _MissingExtraScreen extends StatelessWidget {
  final String message;
  const _MissingExtraScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman tidak tersedia')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go(AppRouter.home),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
