import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sasacation/data/model/checkout_model.dart';
import 'package:sasacation/data/model/hotel_model.dart';
import 'package:sasacation/ui/ai/ai_chat_screen.dart';
import 'package:sasacation/ui/ai/smart_search_screen.dart';
import 'package:sasacation/ui/ai/trip_planner_screen.dart';
import 'package:sasacation/ui/booking/booking_page.dart';
import 'package:sasacation/ui/checkout/booking_confirm_screen.dart';
import 'package:sasacation/ui/checkout/checkout_screen.dart';
import 'package:sasacation/ui/hotels/adminpanel/admin_panel_page.dart';
import 'package:sasacation/ui/hotels/detail_hotels_page.dart';
import 'package:sasacation/ui/login/login_page.dart';
import 'package:sasacation/ui/main_navigation_page.dart';
import 'package:sasacation/ui/onboarding/onboarding_page.dart';
import 'package:sasacation/ui/search/search_results_page.dart';
import 'package:sasacation/ui/splash/splash_page.dart';
import 'package:sasacation/ui/wishlist/wishlist_page.dart';
import 'package:sasacation/viewmodel/search/hotel_search_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static const String splash         = '/';
  static const String onboarding     = '/onboarding';
  static const String login          = '/login';
  static const String home           = '/home';
  static const String hotelDetail    = '/hotel-detail/:id';
  static const String searchResults  = '/search-results';
  static const String wishlist       = '/wishlist';
  static const String myBookings     = '/my-bookings';
  static const String admin          = '/admin';
  // Checkout flow
  static const String checkout       = '/checkout';
  static const String bookingConfirm = '/booking-confirm';
  // AI
  static const String aiChat         = '/ai-chat';
  static const String smartSearch    = '/smart-search';
  static const String tripPlanner    = '/trip-planner';

  /// Rute yang boleh diakses tanpa login (guest browsing), meniru pola OTA:
  /// pengguna bisa melihat-lihat hotel bebas, login baru wajib saat mau
  /// benar-benar memesan (checkout) atau mengakses data personal.
  static const Set<String> guestAccessible = {
    splash, onboarding, login, home, hotelDetail, searchResults, wishlist,
  };
}

class Routes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRouter.splash,
    routes: [
      // ─── Core ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRouter.onboarding,
        builder: (_, __) => const OnboardingScreen(),
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
      GoRoute(
        path: AppRouter.home,
        builder: (_, __) => const MainNavigation(),
      ),

      // ─── Hotel ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.hotelDetail,
        builder: (_, state) => HotelDetailScreen(
          hotelId: state.pathParameters['id']!,
        ),
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
        builder: (_, __) => const WishlistScreen(),
      ),

      // ─── Booking & Checkout flow ──────────────────────────────────────────
      GoRoute(
        path: AppRouter.myBookings,
        builder: (_, __) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: AppRouter.checkout,
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>;
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
        builder: (_, state) => BookingConfirmScreen(
          result: state.extra as PaymentResult,
        ),
      ),

      // ─── Admin ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.admin,
        builder: (_, __) => const AdminPanelScreen(),
      ),

      // ─── AI ───────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRouter.aiChat,
        builder: (_, __) => const AiChatScreen(),
      ),
      GoRoute(
        path: AppRouter.smartSearch,
        builder: (_, __) => const SmartSearchScreen(),
      ),
      GoRoute(
        path: AppRouter.tripPlanner,
        builder: (_, __) => const TripPlannerScreen(),
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
