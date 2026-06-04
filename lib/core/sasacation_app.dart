import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/repo/ai_repository.dart';
import 'package:sasacation/data/repo/auth_repository.dart';
import 'package:sasacation/data/repo/checkout_repository.dart';
import 'package:sasacation/data/repo/explore_repository.dart';
import 'package:sasacation/data/repo/hotel_repository.dart';
import 'package:sasacation/route/approuter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sasacation/viewmodel/ai/ai_bloc.dart';
import 'package:sasacation/viewmodel/auth/auth_bloc.dart';
import 'package:sasacation/viewmodel/booking/booking_bloc.dart';
import 'package:sasacation/viewmodel/checkout/checkout_bloc.dart';
import 'package:sasacation/viewmodel/explore/explore_bloc.dart';
import 'package:sasacation/viewmodel/hotel/hotel_bloc.dart';

class LombokApp extends StatelessWidget {
  const LombokApp({super.key});

    @override
  Widget build(BuildContext context) {
   return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: AuthRepository())
            ..add(AuthCheckStatusRequested()),
        ),
        BlocProvider<HotelBloc>(
          create: (_) => HotelBloc(hotelRepository: HotelRepository()),
        ),
        BlocProvider<ExploreBloc>(
          create: (_) => ExploreBloc(exploreRepository: ExploreRepository()),
        ),
        BlocProvider<BookingBloc>(
          create: (_) => BookingBloc(bookingRepository: BookingRepository()),
        ),
        BlocProvider<AiBloc>(
          create: (_) => AiBloc(aiRepository: AiRepository()),
        ),
        BlocProvider<CheckoutBloc>(
          create: (_) => CheckoutBloc(repo: CheckoutRepository()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Sasacation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: Routes.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'GB'),
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
}