import 'package:flutter/material.dart';
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
import 'package:sasacation/ui/splash/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static const String splash         = '/';
  static const String onboarding     = '/onboarding';
  static const String login          = '/login';
  static const String home           = '/home';
  static const String hotelDetail    = '/hotel-detail/:id';
  static const String myBookings     = '/my-bookings';
  static const String admin          = '/admin';
  // Checkout flow
  static const String checkout       = '/checkout';
  static const String bookingConfirm = '/booking-confirm';
  // AI
  static const String aiChat         = '/ai-chat';
  static const String smartSearch    = '/smart-search';
  static const String tripPlanner    = '/trip-planner';
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
        builder: (_, __) => const LoginScreen(),
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

      final isPublic = loc == AppRouter.splash ||
          loc == AppRouter.onboarding ||
          loc == AppRouter.login;

      if (!hasSeenOnboarding && loc != AppRouter.onboarding && loc != AppRouter.splash) {
        return AppRouter.onboarding;
      }
      if (hasSeenOnboarding && !isLoggedIn && !isPublic) {
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
