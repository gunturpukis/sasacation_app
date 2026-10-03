import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @auth_aiAskSasa.
  ///
  /// In id, this message translates to:
  /// **'Tanya Sasa'**
  String get auth_aiAskSasa;

  /// No description provided for @auth_aiAskSasaSubtitle.
  ///
  /// In id, this message translates to:
  /// **'AI travel assistant untuk rekomendasi wisata'**
  String get auth_aiAskSasaSubtitle;

  /// No description provided for @auth_aiMenuSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Powered by Sasa AI'**
  String get auth_aiMenuSubtitle;

  /// No description provided for @auth_aiMenuTitle.
  ///
  /// In id, this message translates to:
  /// **'Fitur AI Sasacation'**
  String get auth_aiMenuTitle;

  /// No description provided for @auth_aiSmartSearch.
  ///
  /// In id, this message translates to:
  /// **'Smart Search'**
  String get auth_aiSmartSearch;

  /// No description provided for @auth_aiSmartSearchSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Cari dengan bahasa natural, AI yang memahami'**
  String get auth_aiSmartSearchSubtitle;

  /// No description provided for @auth_aiTooltip.
  ///
  /// In id, this message translates to:
  /// **'Sasa AI'**
  String get auth_aiTooltip;

  /// No description provided for @auth_aiTripPlanner.
  ///
  /// In id, this message translates to:
  /// **'Trip Planner'**
  String get auth_aiTripPlanner;

  /// No description provided for @auth_aiTripPlannerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buat itinerary Lombok otomatis dengan AI'**
  String get auth_aiTripPlannerSubtitle;

  /// No description provided for @auth_loginAlreadyHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? '**
  String get auth_loginAlreadyHaveAccount;

  /// No description provided for @auth_loginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get auth_loginButton;

  /// No description provided for @auth_loginContinueAsGuest.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan sebagai Tamu'**
  String get auth_loginContinueAsGuest;

  /// No description provided for @auth_loginContinueWithApple.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan dengan Apple'**
  String get auth_loginContinueWithApple;

  /// No description provided for @auth_loginContinueWithGoogle.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan dengan Google'**
  String get auth_loginContinueWithGoogle;

  /// No description provided for @auth_loginCreateAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Baru'**
  String get auth_loginCreateAccountTitle;

  /// No description provided for @auth_loginEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get auth_loginEmailInvalid;

  /// No description provided for @auth_loginEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get auth_loginEmailLabel;

  /// No description provided for @auth_loginEmailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email wajib diisi'**
  String get auth_loginEmailRequired;

  /// No description provided for @auth_loginFillEmailFirst.
  ///
  /// In id, this message translates to:
  /// **'Isi email kamu dulu, lalu ketuk Lupa Password lagi'**
  String get auth_loginFillEmailFirst;

  /// No description provided for @auth_loginForgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa Password?'**
  String get auth_loginForgotPassword;

  /// No description provided for @auth_loginFullNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get auth_loginFullNameLabel;

  /// No description provided for @auth_loginGateAction.
  ///
  /// In id, this message translates to:
  /// **'Masuk / Daftar'**
  String get auth_loginGateAction;

  /// No description provided for @auth_loginGateContinueAsGuest.
  ///
  /// In id, this message translates to:
  /// **'Lanjut sebagai tamu'**
  String get auth_loginGateContinueAsGuest;

  /// No description provided for @auth_loginGateMessage.
  ///
  /// In id, this message translates to:
  /// **'Riwayat booking dan profil tersimpan di akunmu. Masuk atau daftar untuk mengaksesnya.'**
  String get auth_loginGateMessage;

  /// No description provided for @auth_loginGateTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan'**
  String get auth_loginGateTitle;

  /// No description provided for @auth_loginNameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get auth_loginNameRequired;

  /// No description provided for @auth_loginNoAccountYet.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? '**
  String get auth_loginNoAccountYet;

  /// No description provided for @auth_loginOrDivider.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get auth_loginOrDivider;

  /// No description provided for @auth_loginPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get auth_loginPasswordLabel;

  /// No description provided for @auth_loginPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Password wajib diisi'**
  String get auth_loginPasswordRequired;

  /// No description provided for @auth_loginPasswordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 6 karakter'**
  String get auth_loginPasswordTooShort;

  /// No description provided for @auth_loginRegisterButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get auth_loginRegisterButton;

  /// No description provided for @auth_loginRegisterSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar dan mulai jelajahi Lombok'**
  String get auth_loginRegisterSubtitle;

  /// No description provided for @auth_loginResetEmailFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim email reset'**
  String get auth_loginResetEmailFailed;

  /// No description provided for @auth_loginResetEmailSent.
  ///
  /// In id, this message translates to:
  /// **'Email reset terkirim ke {email}'**
  String auth_loginResetEmailSent(String email);

  /// No description provided for @auth_loginResetPasswordConfirm.
  ///
  /// In id, this message translates to:
  /// **'Kirim email reset password ke {email}?'**
  String auth_loginResetPasswordConfirm(String email);

  /// No description provided for @auth_loginResetPasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Reset Password'**
  String get auth_loginResetPasswordTitle;

  /// No description provided for @auth_loginSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get auth_loginSend;

  /// No description provided for @auth_loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan ke Sasacation'**
  String get auth_loginSubtitle;

  /// No description provided for @auth_loginWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang! 👋'**
  String get auth_loginWelcomeTitle;

  /// No description provided for @auth_navBookings.
  ///
  /// In id, this message translates to:
  /// **'Bookings'**
  String get auth_navBookings;

  /// No description provided for @auth_navExplore.
  ///
  /// In id, this message translates to:
  /// **'Explore'**
  String get auth_navExplore;

  /// No description provided for @auth_navHome.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get auth_navHome;

  /// No description provided for @auth_navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profile'**
  String get auth_navProfile;

  /// No description provided for @auth_onboardingDescBooking.
  ///
  /// In id, this message translates to:
  /// **'Easy booking for hotels, transport, and tour packages'**
  String get auth_onboardingDescBooking;

  /// No description provided for @auth_onboardingDescCulinary.
  ///
  /// In id, this message translates to:
  /// **'Taste authentic Sasak cuisine and local delicacies'**
  String get auth_onboardingDescCulinary;

  /// No description provided for @auth_onboardingDescExplore.
  ///
  /// In id, this message translates to:
  /// **'Discover beautiful beaches, mountains, and cultural heritage in Lombok'**
  String get auth_onboardingDescExplore;

  /// No description provided for @auth_onboardingExploreAsGuest.
  ///
  /// In id, this message translates to:
  /// **'Jelajahi sebagai Tamu'**
  String get auth_onboardingExploreAsGuest;

  /// No description provided for @auth_onboardingNext.
  ///
  /// In id, this message translates to:
  /// **'Next'**
  String get auth_onboardingNext;

  /// No description provided for @auth_onboardingSkip.
  ///
  /// In id, this message translates to:
  /// **'Skip'**
  String get auth_onboardingSkip;

  /// No description provided for @auth_onboardingTitleBooking.
  ///
  /// In id, this message translates to:
  /// **'Book Hotels & Transport'**
  String get auth_onboardingTitleBooking;

  /// No description provided for @auth_onboardingTitleCulinary.
  ///
  /// In id, this message translates to:
  /// **'Enjoy Local Culinary'**
  String get auth_onboardingTitleCulinary;

  /// No description provided for @auth_onboardingTitleExplore.
  ///
  /// In id, this message translates to:
  /// **'Explore Lombok'**
  String get auth_onboardingTitleExplore;

  /// No description provided for @auth_splashAppName.
  ///
  /// In id, this message translates to:
  /// **'Sasacation'**
  String get auth_splashAppName;

  /// No description provided for @auth_splashTagline.
  ///
  /// In id, this message translates to:
  /// **'Explore the Beauty of Lombok'**
  String get auth_splashTagline;

  /// No description provided for @common_cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get common_cancel;

  /// No description provided for @common_bookNow.
  ///
  /// In id, this message translates to:
  /// **'Book Now'**
  String get common_bookNow;

  /// No description provided for @common_ok.
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_perNight.
  ///
  /// In id, this message translates to:
  /// **' / night'**
  String get common_perNight;

  /// No description provided for @common_retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get common_retry;

  /// No description provided for @common_save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get common_save;

  /// No description provided for @common_seeAll.
  ///
  /// In id, this message translates to:
  /// **'See all'**
  String get common_seeAll;

  /// No description provided for @fun_aboutExperience.
  ///
  /// In id, this message translates to:
  /// **'About the Experience'**
  String get fun_aboutExperience;

  /// No description provided for @fun_aboutFallback.
  ///
  /// In id, this message translates to:
  /// **'Nikmati pengalaman menginap yang tak terlupakan di {name}. Dengan fasilitas lengkap dan layanan prima, hotel ini menawarkan kenyamanan terbaik.'**
  String fun_aboutFallback(String name);

  /// No description provided for @fun_aboutPlace.
  ///
  /// In id, this message translates to:
  /// **'Tentang Tempat Ini'**
  String get fun_aboutPlace;

  /// No description provided for @fun_aiPickDesc.
  ///
  /// In id, this message translates to:
  /// **'Rating tertinggi ({rating}) untuk pencarianmu saat ini.'**
  String fun_aiPickDesc(String rating);

  /// No description provided for @fun_aiPickTitle.
  ///
  /// In id, this message translates to:
  /// **'AI Pick for You'**
  String get fun_aiPickTitle;

  /// No description provided for @fun_allLabel.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get fun_allLabel;

  /// No description provided for @fun_amenitiesMustAll.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas (harus ada semua)'**
  String get fun_amenitiesMustAll;

  /// No description provided for @fun_applyFilter.
  ///
  /// In id, this message translates to:
  /// **'Terapkan Filter'**
  String get fun_applyFilter;

  /// No description provided for @fun_avgPerPerson.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata per orang'**
  String get fun_avgPerPerson;

  /// No description provided for @fun_avgPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga rata-rata'**
  String get fun_avgPrice;

  /// No description provided for @fun_backToHome.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Beranda'**
  String get fun_backToHome;

  /// No description provided for @fun_badgeBestSeller.
  ///
  /// In id, this message translates to:
  /// **'BEST SELLER'**
  String get fun_badgeBestSeller;

  /// No description provided for @fun_badgeMostPopular.
  ///
  /// In id, this message translates to:
  /// **'Most Popular'**
  String get fun_badgeMostPopular;

  /// No description provided for @fun_badgeNewArrivals.
  ///
  /// In id, this message translates to:
  /// **'New Arrivals'**
  String get fun_badgeNewArrivals;

  /// No description provided for @fun_badgePremium.
  ///
  /// In id, this message translates to:
  /// **'PREMIUM ESCAPE'**
  String get fun_badgePremium;

  /// No description provided for @fun_badgeSpecialOffer.
  ///
  /// In id, this message translates to:
  /// **'SPECIAL OFFER'**
  String get fun_badgeSpecialOffer;

  /// No description provided for @fun_badgeTrending.
  ///
  /// In id, this message translates to:
  /// **'TRENDING'**
  String get fun_badgeTrending;

  /// No description provided for @fun_bookingCancelledMsg.
  ///
  /// In id, this message translates to:
  /// **'Booking berhasil dibatalkan'**
  String get fun_bookingCancelledMsg;

  /// No description provided for @fun_bookingCodeCopied.
  ///
  /// In id, this message translates to:
  /// **'Kode booking disalin!'**
  String get fun_bookingCodeCopied;

  /// No description provided for @fun_bookingCodeLabel.
  ///
  /// In id, this message translates to:
  /// **'Kode Booking'**
  String get fun_bookingCodeLabel;

  /// No description provided for @fun_bookingCodeWith.
  ///
  /// In id, this message translates to:
  /// **'Kode: {code}'**
  String fun_bookingCodeWith(String code);

  /// No description provided for @fun_bookYourStay.
  ///
  /// In id, this message translates to:
  /// **'Book Your Stay'**
  String get fun_bookYourStay;

  /// No description provided for @fun_cannotOpenMaps.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka Google Maps'**
  String get fun_cannotOpenMaps;

  /// No description provided for @fun_cannotOpenPayment.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat membuka halaman pembayaran'**
  String get fun_cannotOpenPayment;

  /// No description provided for @fun_cancelBookingAction.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get fun_cancelBookingAction;

  /// No description provided for @fun_cancelBookingConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin membatalkan booking ini?'**
  String get fun_cancelBookingConfirm;

  /// No description provided for @fun_cancelBookingTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan Booking'**
  String get fun_cancelBookingTitle;

  /// No description provided for @fun_cardExp.
  ///
  /// In id, this message translates to:
  /// **'Exp {exp}'**
  String fun_cardExp(String exp);

  /// No description provided for @fun_cardNicknameHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Business'**
  String get fun_cardNicknameHint;

  /// No description provided for @fun_cardNicknameTitle.
  ///
  /// In id, this message translates to:
  /// **'Julukan Kartu'**
  String get fun_cardNicknameTitle;

  /// No description provided for @fun_categoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get fun_categoryLabel;

  /// No description provided for @fun_changeNicknameTip.
  ///
  /// In id, this message translates to:
  /// **'Ganti julukan'**
  String get fun_changeNicknameTip;

  /// No description provided for @fun_checkInLabel.
  ///
  /// In id, this message translates to:
  /// **'Check-in'**
  String get fun_checkInLabel;

  /// No description provided for @fun_checkInUpper.
  ///
  /// In id, this message translates to:
  /// **'CHECK-IN'**
  String get fun_checkInUpper;

  /// No description provided for @fun_checkOutLabel.
  ///
  /// In id, this message translates to:
  /// **'Check-out'**
  String get fun_checkOutLabel;

  /// No description provided for @fun_checkOutUpper.
  ///
  /// In id, this message translates to:
  /// **'CHECK-OUT'**
  String get fun_checkOutUpper;

  /// No description provided for @fun_cleaningFeeLabel.
  ///
  /// In id, this message translates to:
  /// **'Cleaning fee'**
  String get fun_cleaningFeeLabel;

  /// No description provided for @fun_clearAll.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua'**
  String get fun_clearAll;

  /// No description provided for @fun_comingSoonName.
  ///
  /// In id, this message translates to:
  /// **'{name} — coming soon'**
  String fun_comingSoonName(String name);

  /// No description provided for @fun_completeBooking.
  ///
  /// In id, this message translates to:
  /// **'Complete Booking'**
  String get fun_completeBooking;

  /// No description provided for @fun_continueToPayment.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan ke Pembayaran'**
  String get fun_continueToPayment;

  /// No description provided for @fun_cuisineType.
  ///
  /// In id, this message translates to:
  /// **'Jenis Masakan'**
  String get fun_cuisineType;

  /// No description provided for @fun_dialogNo.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get fun_dialogNo;

  /// No description provided for @fun_dialogYesCancel.
  ///
  /// In id, this message translates to:
  /// **'Ya, Batalkan'**
  String get fun_dialogYesCancel;

  /// No description provided for @fun_directionsAction.
  ///
  /// In id, this message translates to:
  /// **'Petunjuk Arah'**
  String get fun_directionsAction;

  /// No description provided for @fun_distanceFromYou.
  ///
  /// In id, this message translates to:
  /// **'{distance} km dari Anda'**
  String fun_distanceFromYou(String distance);

  /// No description provided for @fun_durationLabel.
  ///
  /// In id, this message translates to:
  /// **'Durasi'**
  String get fun_durationLabel;

  /// No description provided for @fun_emptyBookingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Yuk mulai jelajahi Lombok!'**
  String get fun_emptyBookingsSubtitle;

  /// No description provided for @fun_emptyBookingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada booking'**
  String get fun_emptyBookingsTitle;

  /// No description provided for @fun_emptyCategoryBookings.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada booking di kategori ini'**
  String get fun_emptyCategoryBookings;

  /// No description provided for @fun_emptyExploreHint.
  ///
  /// In id, this message translates to:
  /// **'Coba kata kunci lain'**
  String get fun_emptyExploreHint;

  /// No description provided for @fun_emptyExploreTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada tempat ditemukan'**
  String get fun_emptyExploreTitle;

  /// No description provided for @fun_emptyFeatured.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hotel featured'**
  String get fun_emptyFeatured;

  /// No description provided for @fun_emptyNearby.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hotel di sekitar Anda'**
  String get fun_emptyNearby;

  /// No description provided for @fun_emptyWishlistHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk ikon hati pada hotel untuk menyimpannya'**
  String get fun_emptyWishlistHint;

  /// No description provided for @fun_emptyWishlistTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada hotel tersimpan'**
  String get fun_emptyWishlistTitle;

  /// No description provided for @fun_entryTicket.
  ///
  /// In id, this message translates to:
  /// **'Tiket Masuk'**
  String get fun_entryTicket;

  /// No description provided for @fun_estimateRateNote.
  ///
  /// In id, this message translates to:
  /// **'Kurs estimasi — tagihan mengikuti Midtrans'**
  String get fun_estimateRateNote;

  /// No description provided for @fun_estimateSuffix.
  ///
  /// In id, this message translates to:
  /// **' (estimasi)'**
  String get fun_estimateSuffix;

  /// No description provided for @fun_exploreCategory.
  ///
  /// In id, this message translates to:
  /// **'Explore {label}'**
  String fun_exploreCategory(String label);

  /// No description provided for @fun_exploreTitle.
  ///
  /// In id, this message translates to:
  /// **'Explore Lombok'**
  String get fun_exploreTitle;

  /// No description provided for @fun_failedOpenPayment.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuka halaman pembayaran'**
  String get fun_failedOpenPayment;

  /// No description provided for @fun_filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua filter'**
  String get fun_filterAll;

  /// No description provided for @fun_filterAmenities.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas'**
  String get fun_filterAmenities;

  /// No description provided for @fun_filterAmenitiesCount.
  ///
  /// In id, this message translates to:
  /// **'Fasilitas ({count})'**
  String fun_filterAmenitiesCount(num count);

  /// No description provided for @fun_filterPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga'**
  String get fun_filterPrice;

  /// No description provided for @fun_filterPriceActive.
  ///
  /// In id, this message translates to:
  /// **'Harga •'**
  String get fun_filterPriceActive;

  /// No description provided for @fun_filterRating.
  ///
  /// In id, this message translates to:
  /// **'Rating'**
  String get fun_filterRating;

  /// No description provided for @fun_filterRatingValue.
  ///
  /// In id, this message translates to:
  /// **'Rating {value}+'**
  String fun_filterRatingValue(String value);

  /// No description provided for @fun_filterTitle.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get fun_filterTitle;

  /// No description provided for @fun_freeLabel.
  ///
  /// In id, this message translates to:
  /// **'Gratis'**
  String get fun_freeLabel;

  /// No description provided for @fun_guestCountValue.
  ///
  /// In id, this message translates to:
  /// **'{count} orang'**
  String fun_guestCountValue(num count);

  /// No description provided for @fun_guestReviews.
  ///
  /// In id, this message translates to:
  /// **'Guest Reviews'**
  String get fun_guestReviews;

  /// No description provided for @fun_guestReviewsCount.
  ///
  /// In id, this message translates to:
  /// **'Guest Reviews ({count})'**
  String fun_guestReviewsCount(num count);

  /// No description provided for @fun_guestsLabel.
  ///
  /// In id, this message translates to:
  /// **'Tamu'**
  String get fun_guestsLabel;

  /// No description provided for @fun_headlineSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Find your dream vacation with AI assistance'**
  String get fun_headlineSubtitle;

  /// No description provided for @fun_headlineWhereToNext.
  ///
  /// In id, this message translates to:
  /// **'Where to next?'**
  String get fun_headlineWhereToNext;

  /// No description provided for @fun_hotelDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Hotel'**
  String get fun_hotelDetailTitle;

  /// No description provided for @fun_hotelMapHint.
  ///
  /// In id, this message translates to:
  /// **'Peta lokasi hotel — ketuk untuk buka Maps'**
  String get fun_hotelMapHint;

  /// No description provided for @fun_infoHotelLabel.
  ///
  /// In id, this message translates to:
  /// **'Hotel'**
  String get fun_infoHotelLabel;

  /// No description provided for @fun_locationLabel.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get fun_locationLabel;

  /// No description provided for @fun_locationPermissionNeeded.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi dibutuhkan untuk fitur ini'**
  String get fun_locationPermissionNeeded;

  /// No description provided for @fun_mapLocationName.
  ///
  /// In id, this message translates to:
  /// **'Peta lokasi {name}'**
  String fun_mapLocationName(String name);

  /// No description provided for @fun_maxHint.
  ///
  /// In id, this message translates to:
  /// **'Max'**
  String get fun_maxHint;

  /// No description provided for @fun_methodRowLabel.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get fun_methodRowLabel;

  /// No description provided for @fun_minHint.
  ///
  /// In id, this message translates to:
  /// **'Min'**
  String get fun_minHint;

  /// No description provided for @fun_minRatingLabel.
  ///
  /// In id, this message translates to:
  /// **'Rating minimum'**
  String get fun_minRatingLabel;

  /// No description provided for @fun_myBookingsTitle.
  ///
  /// In id, this message translates to:
  /// **'My Bookings'**
  String get fun_myBookingsTitle;

  /// No description provided for @fun_nearbyTitle.
  ///
  /// In id, this message translates to:
  /// **'Hotel Terdekat'**
  String get fun_nearbyTitle;

  /// No description provided for @fun_nicknameUpdated.
  ///
  /// In id, this message translates to:
  /// **'Julukan kartu diperbarui'**
  String get fun_nicknameUpdated;

  /// No description provided for @fun_nightsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} malam'**
  String fun_nightsCount(num count);

  /// No description provided for @fun_nightsLabel.
  ///
  /// In id, this message translates to:
  /// **'Malam'**
  String get fun_nightsLabel;

  /// No description provided for @fun_nightsMultiply.
  ///
  /// In id, this message translates to:
  /// **'× {count} malam'**
  String fun_nightsMultiply(num count);

  /// No description provided for @fun_noActivePayment.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada sesi pembayaran aktif untuk booking ini'**
  String get fun_noActivePayment;

  /// No description provided for @fun_noChargeYet.
  ///
  /// In id, this message translates to:
  /// **'Tidak dikenakan biaya sekarang'**
  String get fun_noChargeYet;

  /// No description provided for @fun_noResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil'**
  String get fun_noResults;

  /// No description provided for @fun_notesHint.
  ///
  /// In id, this message translates to:
  /// **'Mis: kamar di lantai atas, dekat kolam...'**
  String get fun_notesHint;

  /// No description provided for @fun_notesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get fun_notesLabel;

  /// No description provided for @fun_openHours.
  ///
  /// In id, this message translates to:
  /// **'Jam Buka'**
  String get fun_openHours;

  /// No description provided for @fun_paidTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu Bayar'**
  String get fun_paidTimeLabel;

  /// No description provided for @fun_payGroupCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu'**
  String get fun_payGroupCard;

  /// No description provided for @fun_payGroupEWallet.
  ///
  /// In id, this message translates to:
  /// **'E-Wallet'**
  String get fun_payGroupEWallet;

  /// No description provided for @fun_payGroupOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get fun_payGroupOther;

  /// No description provided for @fun_payMethodsTitle.
  ///
  /// In id, this message translates to:
  /// **'Metode Pembayaran'**
  String get fun_payMethodsTitle;

  /// No description provided for @fun_payNow.
  ///
  /// In id, this message translates to:
  /// **'Bayar Sekarang'**
  String get fun_payNow;

  /// No description provided for @fun_paymentBrowserDesc.
  ///
  /// In id, this message translates to:
  /// **'Halaman pembayaran sudah dibuka di browser. Selesaikan pembayaran Anda, lalu kembali ke sini — statusnya akan terupdate otomatis.'**
  String get fun_paymentBrowserDesc;

  /// No description provided for @fun_paymentDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Pembayaran'**
  String get fun_paymentDetailTitle;

  /// No description provided for @fun_paymentExpired.
  ///
  /// In id, this message translates to:
  /// **'Masa bayar habis — tarik untuk memuat ulang status'**
  String get fun_paymentExpired;

  /// No description provided for @fun_paymentSuccessSub.
  ///
  /// In id, this message translates to:
  /// **'Booking kamu sudah dikonfirmasi.\nSelamat berlibur di Lombok!'**
  String get fun_paymentSuccessSub;

  /// No description provided for @fun_paymentSuccessTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran Berhasil! 🎉'**
  String get fun_paymentSuccessTitle;

  /// No description provided for @fun_paymentTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get fun_paymentTitle;

  /// No description provided for @fun_payWithin.
  ///
  /// In id, this message translates to:
  /// **'Bayar dalam {time}'**
  String fun_payWithin(String time);

  /// No description provided for @fun_perPerson.
  ///
  /// In id, this message translates to:
  /// **' / orang'**
  String get fun_perPerson;

  /// No description provided for @fun_photoGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri Foto'**
  String get fun_photoGallery;

  /// No description provided for @fun_placeDescFallback.
  ///
  /// In id, this message translates to:
  /// **'Nikmati keindahan {name} yang terletak di {location}. Salah satu destinasi terbaik di Lombok dengan berbagai daya tarik yang memukau.'**
  String fun_placeDescFallback(String name, String location);

  /// No description provided for @fun_placesFound.
  ///
  /// In id, this message translates to:
  /// **'{count} tempat ditemukan'**
  String fun_placesFound(num count);

  /// No description provided for @fun_pleaseWait.
  ///
  /// In id, this message translates to:
  /// **'Mohon tunggu sebentar'**
  String get fun_pleaseWait;

  /// No description provided for @fun_preparingCheckout.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan checkout...'**
  String get fun_preparingCheckout;

  /// No description provided for @fun_priceBreakdown.
  ///
  /// In id, this message translates to:
  /// **'Rincian Harga'**
  String get fun_priceBreakdown;

  /// No description provided for @fun_pricePerNightRow.
  ///
  /// In id, this message translates to:
  /// **'Harga per malam'**
  String get fun_pricePerNightRow;

  /// No description provided for @fun_pricePerNightTitle.
  ///
  /// In id, this message translates to:
  /// **'Price per night'**
  String get fun_pricePerNightTitle;

  /// No description provided for @fun_priceRangeLabel.
  ///
  /// In id, this message translates to:
  /// **'Rentang harga per malam (\$)'**
  String get fun_priceRangeLabel;

  /// No description provided for @fun_priceVaried.
  ///
  /// In id, this message translates to:
  /// **'Variatif'**
  String get fun_priceVaried;

  /// No description provided for @fun_primaryBadge.
  ///
  /// In id, this message translates to:
  /// **'Utama'**
  String get fun_primaryBadge;

  /// No description provided for @fun_proceedCheckout.
  ///
  /// In id, this message translates to:
  /// **'Lanjut ke Checkout'**
  String get fun_proceedCheckout;

  /// No description provided for @fun_processingPayment.
  ///
  /// In id, this message translates to:
  /// **'Memproses pembayaran...'**
  String get fun_processingPayment;

  /// No description provided for @fun_propertiesFound.
  ///
  /// In id, this message translates to:
  /// **'{count} properti ditemukan'**
  String fun_propertiesFound(num count);

  /// No description provided for @fun_propertyTitle.
  ///
  /// In id, this message translates to:
  /// **'The Property'**
  String get fun_propertyTitle;

  /// No description provided for @fun_quickMenuBookings.
  ///
  /// In id, this message translates to:
  /// **'My Bookings'**
  String get fun_quickMenuBookings;

  /// No description provided for @fun_quickMenuNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifications'**
  String get fun_quickMenuNotifications;

  /// No description provided for @fun_quickMenuSaved.
  ///
  /// In id, this message translates to:
  /// **'Saved Destinations'**
  String get fun_quickMenuSaved;

  /// No description provided for @fun_quickMenuSettings.
  ///
  /// In id, this message translates to:
  /// **'Settings'**
  String get fun_quickMenuSettings;

  /// No description provided for @fun_ratingReviews.
  ///
  /// In id, this message translates to:
  /// **'{rating} ({count} reviews)'**
  String fun_ratingReviews(String rating, num count);

  /// No description provided for @fun_recentSearches.
  ///
  /// In id, this message translates to:
  /// **'Terakhir dicari'**
  String get fun_recentSearches;

  /// No description provided for @fun_renameCardFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengganti nama kartu'**
  String get fun_renameCardFailed;

  /// No description provided for @fun_reopenPayment.
  ///
  /// In id, this message translates to:
  /// **'Buka Lagi Halaman Pembayaran'**
  String get fun_reopenPayment;

  /// No description provided for @fun_rescheduleAction.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Ulang'**
  String get fun_rescheduleAction;

  /// No description provided for @fun_rescheduleDiscount.
  ///
  /// In id, this message translates to:
  /// **'Total baru {total} (selisih {diff} akan disesuaikan).'**
  String fun_rescheduleDiscount(String total, String diff);

  /// No description provided for @fun_rescheduleExtraCost.
  ///
  /// In id, this message translates to:
  /// **'Total baru {total} (+{diff}). Pembayaran tambahan belum otomatis — hubungi CS bila perlu.'**
  String fun_rescheduleExtraCost(String total, String diff);

  /// No description provided for @fun_rescheduleFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menjadwalkan ulang'**
  String get fun_rescheduleFailed;

  /// No description provided for @fun_rescheduleNoDiff.
  ///
  /// In id, this message translates to:
  /// **'Tanggal berhasil diubah tanpa selisih harga.'**
  String get fun_rescheduleNoDiff;

  /// No description provided for @fun_rescheduleUpdated.
  ///
  /// In id, this message translates to:
  /// **'Jadwal Diperbarui'**
  String get fun_rescheduleUpdated;

  /// No description provided for @fun_reservationSoon.
  ///
  /// In id, this message translates to:
  /// **'Fitur reservasi akan segera hadir!'**
  String get fun_reservationSoon;

  /// No description provided for @fun_reserveAction.
  ///
  /// In id, this message translates to:
  /// **'Reservasi'**
  String get fun_reserveAction;

  /// No description provided for @fun_reviewBookingTitle.
  ///
  /// In id, this message translates to:
  /// **'Review Booking'**
  String get fun_reviewBookingTitle;

  /// No description provided for @fun_reviewCountLabel.
  ///
  /// In id, this message translates to:
  /// **'({count} ulasan)'**
  String fun_reviewCountLabel(num count);

  /// No description provided for @fun_saveCardSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Munculkan opsi simpan di halaman pembayaran untuk pemakaian berikutnya'**
  String get fun_saveCardSubtitle;

  /// No description provided for @fun_saveCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan kartu ini'**
  String get fun_saveCardTitle;

  /// No description provided for @fun_saveCodeHint.
  ///
  /// In id, this message translates to:
  /// **'Simpan kode ini untuk referensi kamu'**
  String get fun_saveCodeHint;

  /// No description provided for @fun_savedFavoriteSoon.
  ///
  /// In id, this message translates to:
  /// **'{name} disimpan ke favorit (segera hadir penuh)'**
  String fun_savedFavoriteSoon(String name);

  /// No description provided for @fun_savedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Discover your dream vacations waiting for you.'**
  String get fun_savedSubtitle;

  /// No description provided for @fun_savedTitle.
  ///
  /// In id, this message translates to:
  /// **'Saved Destinations'**
  String get fun_savedTitle;

  /// No description provided for @fun_savedCardsTitle.
  ///
  /// In id, this message translates to:
  /// **'Kartu Tersimpan'**
  String get fun_savedCardsTitle;

  /// No description provided for @fun_searchHint.
  ///
  /// In id, this message translates to:
  /// **'Search destinations, villas, or activities...'**
  String get fun_searchHint;

  /// No description provided for @fun_searchHotelHint.
  ///
  /// In id, this message translates to:
  /// **'Cari hotel atau lokasi...'**
  String get fun_searchHotelHint;

  /// No description provided for @fun_sectionPopularCategories.
  ///
  /// In id, this message translates to:
  /// **'Popular Categories'**
  String get fun_sectionPopularCategories;

  /// No description provided for @fun_sectionRecommended.
  ///
  /// In id, this message translates to:
  /// **'Recommended for You'**
  String get fun_sectionRecommended;

  /// No description provided for @fun_sectionTrending.
  ///
  /// In id, this message translates to:
  /// **'Trending This Week'**
  String get fun_sectionTrending;

  /// No description provided for @fun_selectPayMethod.
  ///
  /// In id, this message translates to:
  /// **'Pilih Metode Pembayaran'**
  String get fun_selectPayMethod;

  /// No description provided for @fun_sortByTitle.
  ///
  /// In id, this message translates to:
  /// **'Urutkan berdasarkan'**
  String get fun_sortByTitle;

  /// No description provided for @fun_sortCheapest.
  ///
  /// In id, this message translates to:
  /// **'Termurah'**
  String get fun_sortCheapest;

  /// No description provided for @fun_sortDefault.
  ///
  /// In id, this message translates to:
  /// **'Urutkan'**
  String get fun_sortDefault;

  /// No description provided for @fun_sortExpensive.
  ///
  /// In id, this message translates to:
  /// **'Termahal'**
  String get fun_sortExpensive;

  /// No description provided for @fun_sortNewest.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get fun_sortNewest;

  /// No description provided for @fun_sortPriceHigh.
  ///
  /// In id, this message translates to:
  /// **'Harga tertinggi'**
  String get fun_sortPriceHigh;

  /// No description provided for @fun_sortPriceLow.
  ///
  /// In id, this message translates to:
  /// **'Harga terendah'**
  String get fun_sortPriceLow;

  /// No description provided for @fun_sortRatingHigh.
  ///
  /// In id, this message translates to:
  /// **'Rating tertinggi'**
  String get fun_sortRatingHigh;

  /// No description provided for @fun_specialNotesLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan khusus (opsional)'**
  String get fun_specialNotesLabel;

  /// No description provided for @fun_statusCancelled.
  ///
  /// In id, this message translates to:
  /// **'Cancelled'**
  String get fun_statusCancelled;

  /// No description provided for @fun_statusCompleted.
  ///
  /// In id, this message translates to:
  /// **'Completed'**
  String get fun_statusCompleted;

  /// No description provided for @fun_statusConfirmed.
  ///
  /// In id, this message translates to:
  /// **'Confirmed'**
  String get fun_statusConfirmed;

  /// No description provided for @fun_statusPending.
  ///
  /// In id, this message translates to:
  /// **'Pending'**
  String get fun_statusPending;

  /// No description provided for @fun_statusRowLabel.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get fun_statusRowLabel;

  /// No description provided for @fun_statusSuccess.
  ///
  /// In id, this message translates to:
  /// **'✅ Berhasil'**
  String get fun_statusSuccess;

  /// No description provided for @fun_stayDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Menginap'**
  String get fun_stayDetailTitle;

  /// No description provided for @fun_staySummary.
  ///
  /// In id, this message translates to:
  /// **'{nights} malam · {guests} tamu'**
  String fun_staySummary(num nights, num guests);

  /// No description provided for @fun_stayedWith.
  ///
  /// In id, this message translates to:
  /// **'Stayed: {stayed}'**
  String fun_stayedWith(String stayed);

  /// No description provided for @fun_stepPayment.
  ///
  /// In id, this message translates to:
  /// **'2. Pembayaran'**
  String get fun_stepPayment;

  /// No description provided for @fun_stepReview.
  ///
  /// In id, this message translates to:
  /// **'1. Review'**
  String get fun_stepReview;

  /// No description provided for @fun_subtotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get fun_subtotalLabel;

  /// No description provided for @fun_tabActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get fun_tabActive;

  /// No description provided for @fun_tabCancelled.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get fun_tabCancelled;

  /// No description provided for @fun_tabCompleted.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get fun_tabCompleted;

  /// No description provided for @fun_taxLabel.
  ///
  /// In id, this message translates to:
  /// **'Pajak ({rate}%)'**
  String fun_taxLabel(String rate);

  /// No description provided for @fun_taxServiceNote.
  ///
  /// In id, this message translates to:
  /// **'+ pajak & biaya layanan'**
  String get fun_taxServiceNote;

  /// No description provided for @fun_totalLabel.
  ///
  /// In id, this message translates to:
  /// **'Total:'**
  String get fun_totalLabel;

  /// No description provided for @fun_totalPayment.
  ///
  /// In id, this message translates to:
  /// **'Total Pembayaran'**
  String get fun_totalPayment;

  /// No description provided for @fun_totalRowLabel.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get fun_totalRowLabel;

  /// No description provided for @fun_transactionIdLabel.
  ///
  /// In id, this message translates to:
  /// **'Transaction ID'**
  String get fun_transactionIdLabel;

  /// No description provided for @fun_viewAllBookings.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua Booking'**
  String get fun_viewAllBookings;

  /// No description provided for @fun_viewDetail.
  ///
  /// In id, this message translates to:
  /// **'Lihat Detail'**
  String get fun_viewDetail;

  /// No description provided for @fun_waitingPayment.
  ///
  /// In id, this message translates to:
  /// **'Menunggu pembayaran...'**
  String get fun_waitingPayment;

  /// No description provided for @fun_whatsIncluded.
  ///
  /// In id, this message translates to:
  /// **'What\'s Included'**
  String get fun_whatsIncluded;

  /// No description provided for @fun_resetFilters.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get fun_resetFilters;

  /// No description provided for @fun_serviceFeeLabel.
  ///
  /// In id, this message translates to:
  /// **'Biaya layanan'**
  String get fun_serviceFeeLabel;

  /// No description provided for @fun_sortRecommended.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi'**
  String get fun_sortRecommended;

  /// No description provided for @common_signOut.
  ///
  /// In id, this message translates to:
  /// **'Sign Out'**
  String get common_signOut;

  /// No description provided for @me_actionRequired.
  ///
  /// In id, this message translates to:
  /// **'Action Required'**
  String get me_actionRequired;

  /// No description provided for @me_actionViewBooking.
  ///
  /// In id, this message translates to:
  /// **'Lihat Booking'**
  String get me_actionViewBooking;

  /// No description provided for @me_actionViewGroup.
  ///
  /// In id, this message translates to:
  /// **'Lihat Grup'**
  String get me_actionViewGroup;

  /// No description provided for @me_actionViewHotel.
  ///
  /// In id, this message translates to:
  /// **'Lihat Hotel'**
  String get me_actionViewHotel;

  /// No description provided for @me_actionViewImpact.
  ///
  /// In id, this message translates to:
  /// **'Lihat Dampak'**
  String get me_actionViewImpact;

  /// No description provided for @me_actionViewItinerary.
  ///
  /// In id, this message translates to:
  /// **'Lihat Itinerary'**
  String get me_actionViewItinerary;

  /// No description provided for @me_actionViewTasks.
  ///
  /// In id, this message translates to:
  /// **'Lihat Tasks'**
  String get me_actionViewTasks;

  /// No description provided for @me_actionViewWallet.
  ///
  /// In id, this message translates to:
  /// **'Lihat Wallet'**
  String get me_actionViewWallet;

  /// No description provided for @me_actionVoteNow.
  ///
  /// In id, this message translates to:
  /// **'Vote now'**
  String get me_actionVoteNow;

  /// No description provided for @me_adminBadge.
  ///
  /// In id, this message translates to:
  /// **'Admin'**
  String get me_adminBadge;

  /// No description provided for @me_aiDisabledMsg.
  ///
  /// In id, this message translates to:
  /// **'Personalisasi AI dimatikan — kartu AI Pick disembunyikan dari hasil pencarian'**
  String get me_aiDisabledMsg;

  /// No description provided for @me_aiEnabledMsg.
  ///
  /// In id, this message translates to:
  /// **'Personalisasi AI diaktifkan'**
  String get me_aiEnabledMsg;

  /// No description provided for @me_aiSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi AI berdasarkan riwayat dan preferensimu'**
  String get me_aiSubtitle;

  /// No description provided for @me_aiTitle.
  ///
  /// In id, this message translates to:
  /// **'Personalisasi AI'**
  String get me_aiTitle;

  /// No description provided for @me_amountUsd.
  ///
  /// In id, this message translates to:
  /// **'Jumlah (USD)'**
  String get me_amountUsd;

  /// No description provided for @me_appVersion.
  ///
  /// In id, this message translates to:
  /// **'App Version'**
  String get me_appVersion;

  /// No description provided for @me_categoryBooking.
  ///
  /// In id, this message translates to:
  /// **'Booking'**
  String get me_categoryBooking;

  /// No description provided for @me_categoryInfo.
  ///
  /// In id, this message translates to:
  /// **'Info'**
  String get me_categoryInfo;

  /// No description provided for @me_categoryPayment.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get me_categoryPayment;

  /// No description provided for @me_changePassword.
  ///
  /// In id, this message translates to:
  /// **'Ubah Password'**
  String get me_changePassword;

  /// No description provided for @me_chooseLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa / Choose Language'**
  String get me_chooseLanguage;

  /// No description provided for @me_confirmMismatch.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi tidak sama'**
  String get me_confirmMismatch;

  /// No description provided for @me_confirmPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password baru'**
  String get me_confirmPasswordHint;

  /// No description provided for @me_confirmedBadge.
  ///
  /// In id, this message translates to:
  /// **'CONFIRMED'**
  String get me_confirmedBadge;

  /// No description provided for @me_currentPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Password saat ini'**
  String get me_currentPasswordHint;

  /// No description provided for @me_currentPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Password saat ini wajib diisi'**
  String get me_currentPasswordRequired;

  /// No description provided for @me_daysAgo.
  ///
  /// In id, this message translates to:
  /// **'{days} hari lalu'**
  String me_daysAgo(num days);

  /// No description provided for @me_daysLeft.
  ///
  /// In id, this message translates to:
  /// **'Dalam {daysLeft} Hari'**
  String me_daysLeft(num daysLeft);

  /// No description provided for @me_discoveryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Rekomendasi belum tersedia saat ini'**
  String get me_discoveryEmpty;

  /// No description provided for @me_discoveryFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat rekomendasi'**
  String get me_discoveryFailed;

  /// No description provided for @me_discoverySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bosan dengan rekomendasi yang dipersonalisasi? Temukan tempat yang 100% berbeda dari kebiasaan Anda.'**
  String get me_discoverySubtitle;

  /// No description provided for @me_discoveryTitle.
  ///
  /// In id, this message translates to:
  /// **'Anti-Algorithm Discovery'**
  String get me_discoveryTitle;

  /// No description provided for @me_emailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get me_emailLabel;

  /// No description provided for @me_emailLockedNote.
  ///
  /// In id, this message translates to:
  /// **'Email terikat akun login dan tidak dapat diubah.'**
  String get me_emailLockedNote;

  /// No description provided for @me_emailUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Email akun tidak tersedia. Silakan login ulang.'**
  String get me_emailUnavailable;

  /// No description provided for @me_emptyFilter.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada notifikasi {filter}'**
  String me_emptyFilter(String filter);

  /// No description provided for @me_emptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi tentang booking & pembayaranmu akan muncul di sini'**
  String get me_emptySubtitle;

  /// No description provided for @me_emptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada notifikasi'**
  String get me_emptyTitle;

  /// No description provided for @me_fallbackDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get me_fallbackDone;

  /// No description provided for @me_filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get me_filterAll;

  /// No description provided for @me_fullNameHint.
  ///
  /// In id, this message translates to:
  /// **'Nama lengkap'**
  String get me_fullNameHint;

  /// No description provided for @me_fullNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get me_fullNameLabel;

  /// No description provided for @me_groupOlder.
  ///
  /// In id, this message translates to:
  /// **'Lebih lama'**
  String get me_groupOlder;

  /// No description provided for @me_groupToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get me_groupToday;

  /// No description provided for @me_groupWeek.
  ///
  /// In id, this message translates to:
  /// **'Minggu ini'**
  String get me_groupWeek;

  /// No description provided for @me_guestName.
  ///
  /// In id, this message translates to:
  /// **'Guest'**
  String get me_guestName;

  /// No description provided for @me_helpCenterSoon.
  ///
  /// In id, this message translates to:
  /// **'Pusat bantuan segera hadir di versi berikutnya'**
  String get me_helpCenterSoon;

  /// No description provided for @me_heroBody.
  ///
  /// In id, this message translates to:
  /// **'Sasacation percaya pariwisata Lombok yang berkelanjutan dimulai dari pilihan kecil setiap wisatawan — dari akomodasi yang dipilih sampai siapa yang menerima manfaatnya.'**
  String get me_heroBody;

  /// No description provided for @me_heroTitle.
  ///
  /// In id, this message translates to:
  /// **'Wisata yang Bertanggung Jawab'**
  String get me_heroTitle;

  /// No description provided for @me_hoursAgo.
  ///
  /// In id, this message translates to:
  /// **'{hours} jam lalu'**
  String me_hoursAgo(num hours);

  /// No description provided for @me_impactNote.
  ///
  /// In id, this message translates to:
  /// **'Skor dampak personal dan sertifikat per-user belum ditampilkan — fitur itu butuh sistem tracking yang belum ada. Bagian discovery di atas sudah memakai data rekomendasi nyata dari server.'**
  String get me_impactNote;

  /// No description provided for @me_justNow.
  ///
  /// In id, this message translates to:
  /// **'Baru saja'**
  String get me_justNow;

  /// No description provided for @me_langEnSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Secondary language'**
  String get me_langEnSubtitle;

  /// No description provided for @me_langIdSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa utama aplikasi'**
  String get me_langIdSubtitle;

  /// No description provided for @me_languageTitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa / Language'**
  String get me_languageTitle;

  /// No description provided for @me_logoutConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin keluar dari akun?'**
  String get me_logoutConfirm;

  /// No description provided for @me_logoutTitle.
  ///
  /// In id, this message translates to:
  /// **'Logout'**
  String get me_logoutTitle;

  /// No description provided for @me_loyaltyPoints.
  ///
  /// In id, this message translates to:
  /// **'{points} pts'**
  String me_loyaltyPoints(num points);

  /// No description provided for @me_matchInfo.
  ///
  /// In id, this message translates to:
  /// **'{matchPct}% Match with Your History'**
  String me_matchInfo(num matchPct);

  /// No description provided for @me_menuHelpCenter.
  ///
  /// In id, this message translates to:
  /// **'Help Center'**
  String get me_menuHelpCenter;

  /// No description provided for @me_menuMyBookings.
  ///
  /// In id, this message translates to:
  /// **'My Bookings'**
  String get me_menuMyBookings;

  /// No description provided for @me_menuMyGroups.
  ///
  /// In id, this message translates to:
  /// **'My Groups'**
  String get me_menuMyGroups;

  /// No description provided for @me_menuNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifications'**
  String get me_menuNotifications;

  /// No description provided for @me_menuPaymentHistory.
  ///
  /// In id, this message translates to:
  /// **'Payment History'**
  String get me_menuPaymentHistory;

  /// No description provided for @me_menuPersonalInfo.
  ///
  /// In id, this message translates to:
  /// **'Personal Information'**
  String get me_menuPersonalInfo;

  /// No description provided for @me_menuSavedPlaces.
  ///
  /// In id, this message translates to:
  /// **'Saved Places'**
  String get me_menuSavedPlaces;

  /// No description provided for @me_menuSettings.
  ///
  /// In id, this message translates to:
  /// **'Settings'**
  String get me_menuSettings;

  /// No description provided for @me_menuSustainability.
  ///
  /// In id, this message translates to:
  /// **'Komitmen Sasacation'**
  String get me_menuSustainability;

  /// No description provided for @me_menuTestPush.
  ///
  /// In id, this message translates to:
  /// **'Test Push Notification'**
  String get me_menuTestPush;

  /// No description provided for @me_menuTravelTasks.
  ///
  /// In id, this message translates to:
  /// **'Travel Tasks'**
  String get me_menuTravelTasks;

  /// No description provided for @me_minutesAgo.
  ///
  /// In id, this message translates to:
  /// **'{minutes} menit lalu'**
  String me_minutesAgo(num minutes);

  /// No description provided for @me_nameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi'**
  String get me_nameRequired;

  /// No description provided for @me_newPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Password baru (min. 8 karakter)'**
  String get me_newPasswordHint;

  /// No description provided for @me_newPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Password baru wajib diisi'**
  String get me_newPasswordRequired;

  /// No description provided for @me_nightsCount.
  ///
  /// In id, this message translates to:
  /// **'{nights} malam'**
  String me_nightsCount(num nights);

  /// No description provided for @me_noTransactions.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get me_noTransactions;

  /// No description provided for @me_notifHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Notifikasi'**
  String get me_notifHistory;

  /// No description provided for @me_notificationsTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifications'**
  String get me_notificationsTitle;

  /// No description provided for @me_passMeta.
  ///
  /// In id, this message translates to:
  /// **'ID {passId} • {tripsCompleted} trip selesai'**
  String me_passMeta(String passId, num tripsCompleted);

  /// No description provided for @me_passwordChangeFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengubah password'**
  String get me_passwordChangeFailed;

  /// No description provided for @me_passwordChanged.
  ///
  /// In id, this message translates to:
  /// **'Password berhasil diubah'**
  String get me_passwordChanged;

  /// No description provided for @me_passwordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 8 karakter'**
  String get me_passwordMinLength;

  /// No description provided for @me_passwordRule.
  ///
  /// In id, this message translates to:
  /// **'Password baru minimal 8 karakter (aturan server).'**
  String get me_passwordRule;

  /// No description provided for @me_personalInfoSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Update your details'**
  String get me_personalInfoSubtitle;

  /// No description provided for @me_principleCultureDesc.
  ///
  /// In id, this message translates to:
  /// **'Kami mendorong wisatawan untuk mengenal dan menghormati adat serta kebiasaan masyarakat Sasak dan komunitas lokal lainnya di Lombok.'**
  String get me_principleCultureDesc;

  /// No description provided for @me_principleCultureTitle.
  ///
  /// In id, this message translates to:
  /// **'Hormat pada Budaya Lokal'**
  String get me_principleCultureTitle;

  /// No description provided for @me_principleEcoDesc.
  ///
  /// In id, this message translates to:
  /// **'Kami merekomendasikan mitra yang menerapkan praktik ramah lingkungan — pengelolaan sampah, konservasi terumbu karang, dan penggunaan sumber daya yang bertanggung jawab.'**
  String get me_principleEcoDesc;

  /// No description provided for @me_principleEcoTitle.
  ///
  /// In id, this message translates to:
  /// **'Minim Sampah, Hormati Alam'**
  String get me_principleEcoTitle;

  /// No description provided for @me_principleLocalDesc.
  ///
  /// In id, this message translates to:
  /// **'Kami mendorong penginapan, restoran, dan penyedia aktivitas yang dikelola langsung oleh warga Lombok untuk lebih mudah ditemukan di platform ini.'**
  String get me_principleLocalDesc;

  /// No description provided for @me_principleLocalTitle.
  ///
  /// In id, this message translates to:
  /// **'Dukungan ke Pelaku Usaha Lokal'**
  String get me_principleLocalTitle;

  /// No description provided for @me_profileTitle.
  ///
  /// In id, this message translates to:
  /// **'Profile'**
  String get me_profileTitle;

  /// No description provided for @me_profileUpdated.
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil diperbarui'**
  String get me_profileUpdated;

  /// No description provided for @me_pushDisabledMsg.
  ///
  /// In id, this message translates to:
  /// **'Push notification dimatikan — kamu tidak akan menerima notifikasi booking di device ini'**
  String get me_pushDisabledMsg;

  /// No description provided for @me_pushEnabledMsg.
  ///
  /// In id, this message translates to:
  /// **'Push notification diaktifkan'**
  String get me_pushEnabledMsg;

  /// No description provided for @me_pushSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Update booking, konfirmasi pembayaran, dan info penting lainnya'**
  String get me_pushSubtitle;

  /// No description provided for @me_pushTitle.
  ///
  /// In id, this message translates to:
  /// **'Push Notifications'**
  String get me_pushTitle;

  /// No description provided for @me_recipientEmail.
  ///
  /// In id, this message translates to:
  /// **'Email penerima'**
  String get me_recipientEmail;

  /// No description provided for @me_resetFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengirim email reset'**
  String get me_resetFailed;

  /// No description provided for @me_resetSent.
  ///
  /// In id, this message translates to:
  /// **'Email reset terkirim ke {email}'**
  String me_resetSent(String email);

  /// No description provided for @me_saveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan ke server'**
  String get me_saveFailed;

  /// No description provided for @me_sectionAbout.
  ///
  /// In id, this message translates to:
  /// **'ABOUT'**
  String get me_sectionAbout;

  /// No description provided for @me_sectionAccount.
  ///
  /// In id, this message translates to:
  /// **'ACCOUNT'**
  String get me_sectionAccount;

  /// No description provided for @me_sectionAccountMgmt.
  ///
  /// In id, this message translates to:
  /// **'ACCOUNT MANAGEMENT'**
  String get me_sectionAccountMgmt;

  /// No description provided for @me_sectionGeneral.
  ///
  /// In id, this message translates to:
  /// **'GENERAL'**
  String get me_sectionGeneral;

  /// No description provided for @me_sectionNotifications.
  ///
  /// In id, this message translates to:
  /// **'NOTIFICATIONS'**
  String get me_sectionNotifications;

  /// No description provided for @me_sectionSasaAi.
  ///
  /// In id, this message translates to:
  /// **'SASA AI'**
  String get me_sectionSasaAi;

  /// No description provided for @me_securitySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Change your credentials'**
  String get me_securitySubtitle;

  /// No description provided for @me_securityTitle.
  ///
  /// In id, this message translates to:
  /// **'Security & Password'**
  String get me_securityTitle;

  /// No description provided for @me_seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get me_seeAll;

  /// No description provided for @me_sendAction.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get me_sendAction;

  /// No description provided for @me_sendResetEmail.
  ///
  /// In id, this message translates to:
  /// **'Kirim email reset password'**
  String get me_sendResetEmail;

  /// No description provided for @me_sending.
  ///
  /// In id, this message translates to:
  /// **'Mengirim...'**
  String get me_sending;

  /// No description provided for @me_sendingTestNotification.
  ///
  /// In id, this message translates to:
  /// **'Mengirim test notification...'**
  String get me_sendingTestNotification;

  /// No description provided for @me_settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Settings'**
  String get me_settingsTitle;

  /// No description provided for @me_shuffleAction.
  ///
  /// In id, this message translates to:
  /// **'Guncang untuk Temukan'**
  String get me_shuffleAction;

  /// No description provided for @me_statusFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal'**
  String get me_statusFailed;

  /// No description provided for @me_statusRefunded.
  ///
  /// In id, this message translates to:
  /// **'Dikembalikan'**
  String get me_statusRefunded;

  /// No description provided for @me_statusSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil'**
  String get me_statusSuccess;

  /// No description provided for @me_successTxCount.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi berhasil'**
  String me_successTxCount(num count);

  /// No description provided for @me_totalSpent.
  ///
  /// In id, this message translates to:
  /// **'Total Dibelanjakan'**
  String get me_totalSpent;

  /// No description provided for @me_transferFailed.
  ///
  /// In id, this message translates to:
  /// **'Transfer gagal'**
  String get me_transferFailed;

  /// No description provided for @me_transferNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get me_transferNote;

  /// No description provided for @me_transferSuccess.
  ///
  /// In id, this message translates to:
  /// **'Transfer berhasil'**
  String get me_transferSuccess;

  /// No description provided for @me_transferTitle.
  ///
  /// In id, this message translates to:
  /// **'Transfer Saldo'**
  String get me_transferTitle;

  /// No description provided for @me_travelPass.
  ///
  /// In id, this message translates to:
  /// **'Sasacation Travel Pass'**
  String get me_travelPass;

  /// No description provided for @me_tripsCompleted.
  ///
  /// In id, this message translates to:
  /// **'{completedCount} Trips Completed'**
  String me_tripsCompleted(num completedCount);

  /// No description provided for @me_txHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Transaksi'**
  String get me_txHistory;

  /// No description provided for @me_upcomingTrips.
  ///
  /// In id, this message translates to:
  /// **'Upcoming Trips'**
  String get me_upcomingTrips;

  /// No description provided for @ait_chatHint.
  ///
  /// In id, this message translates to:
  /// **'Ask Sasa anything...'**
  String get ait_chatHint;

  /// No description provided for @ait_chatPlanMeta.
  ///
  /// In id, this message translates to:
  /// **'{days} hari • {cost}'**
  String ait_chatPlanMeta(num days, String cost);

  /// No description provided for @ait_chatResetTooltip.
  ///
  /// In id, this message translates to:
  /// **'Reset chat'**
  String get ait_chatResetTooltip;

  /// No description provided for @ait_chatSubtitle.
  ///
  /// In id, this message translates to:
  /// **'TRAVEL ASSISTANT'**
  String get ait_chatSubtitle;

  /// No description provided for @ait_chatTitle.
  ///
  /// In id, this message translates to:
  /// **'Sasa AI'**
  String get ait_chatTitle;

  /// No description provided for @ait_chatTyping.
  ///
  /// In id, this message translates to:
  /// **'Sasa sedang mengetik...'**
  String get ait_chatTyping;

  /// No description provided for @ait_chatWelcomeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'AI travel assistant kamu untuk menjelajahi Lombok. Tanya apa saja!'**
  String get ait_chatWelcomeSubtitle;

  /// No description provided for @ait_chatWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Halo! Saya Sasa 👋'**
  String get ait_chatWelcomeTitle;

  /// No description provided for @ait_expenseAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get ait_expenseAdd;

  /// No description provided for @ait_expenseAddFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menambah pengeluaran'**
  String get ait_expenseAddFailed;

  /// No description provided for @ait_expenseAmountLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah (USD)'**
  String get ait_expenseAmountLabel;

  /// No description provided for @ait_expenseDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus pengeluaran'**
  String get ait_expenseDeleteFailed;

  /// No description provided for @ait_expenseEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran tercatat.'**
  String get ait_expenseEmpty;

  /// No description provided for @ait_expenseFab.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get ait_expenseFab;

  /// No description provided for @ait_expenseListTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran ({count})'**
  String ait_expenseListTitle(num count);

  /// No description provided for @ait_expenseNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get ait_expenseNameLabel;

  /// No description provided for @ait_expenseNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran Baru'**
  String get ait_expenseNewTitle;

  /// No description provided for @ait_gapDetectedDesc.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran grup {pct}% di atas budget bersama. Pertimbangkan alternatif yang lebih hemat.'**
  String ait_gapDetectedDesc(String pct);

  /// No description provided for @ait_gapDetectedTitle.
  ///
  /// In id, this message translates to:
  /// **'Spending Gap Detected'**
  String get ait_gapDetectedTitle;

  /// No description provided for @ait_groupBudgetBadge.
  ///
  /// In id, this message translates to:
  /// **'GROUP BUDGET'**
  String get ait_groupBudgetBadge;

  /// No description provided for @ait_groupBudgetLabel.
  ///
  /// In id, this message translates to:
  /// **'Budget total (opsional)'**
  String get ait_groupBudgetLabel;

  /// No description provided for @ait_groupCreateFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat grup'**
  String get ait_groupCreateFailed;

  /// No description provided for @ait_groupDestLabel.
  ///
  /// In id, this message translates to:
  /// **'Destinasi (opsional)'**
  String get ait_groupDestLabel;

  /// No description provided for @ait_groupDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Group'**
  String get ait_groupDetailTitle;

  /// No description provided for @ait_groupEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buat grup untuk patungan budget trip bareng.'**
  String get ait_groupEmptySubtitle;

  /// No description provided for @ait_groupEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada grup'**
  String get ait_groupEmptyTitle;

  /// No description provided for @ait_groupEquityBadge.
  ///
  /// In id, this message translates to:
  /// **'GROUP BUDGET EQUITY'**
  String get ait_groupEquityBadge;

  /// No description provided for @ait_groupListTitle.
  ///
  /// In id, this message translates to:
  /// **'My Groups'**
  String get ait_groupListTitle;

  /// No description provided for @ait_groupMembers.
  ///
  /// In id, this message translates to:
  /// **'{count} anggota'**
  String ait_groupMembers(num count);

  /// No description provided for @ait_groupMembersTitle.
  ///
  /// In id, this message translates to:
  /// **'Anggota ({count})'**
  String ait_groupMembersTitle(num count);

  /// No description provided for @ait_groupNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama grup'**
  String get ait_groupNameLabel;

  /// No description provided for @ait_groupNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Grup Baru'**
  String get ait_groupNewTitle;

  /// No description provided for @ait_groupNotFound.
  ///
  /// In id, this message translates to:
  /// **'Grup tidak ditemukan'**
  String get ait_groupNotFound;

  /// No description provided for @ait_groupOf.
  ///
  /// In id, this message translates to:
  /// **'dari'**
  String get ait_groupOf;

  /// No description provided for @ait_groupOverBadge.
  ///
  /// In id, this message translates to:
  /// **'+{pct}% over'**
  String ait_groupOverBadge(String pct);

  /// No description provided for @ait_groupRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa'**
  String get ait_groupRemaining;

  /// No description provided for @ait_groupUsedFrom.
  ///
  /// In id, this message translates to:
  /// **'terpakai dari'**
  String get ait_groupUsedFrom;

  /// No description provided for @ait_memberPaidShare.
  ///
  /// In id, this message translates to:
  /// **'Bayar {paid} • Bagian {share}'**
  String ait_memberPaidShare(String paid, String share);

  /// No description provided for @ait_planTipsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tips'**
  String get ait_planTipsTitle;

  /// No description provided for @ait_planTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Estimasi total: '**
  String get ait_planTotalLabel;

  /// No description provided for @ait_plannerCreateFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat rencana: {error}'**
  String ait_plannerCreateFailed(String error);

  /// No description provided for @ait_plannerEmpty.
  ///
  /// In id, this message translates to:
  /// **'Deskripsikan liburan impian Anda dan biarkan Sasa membuatkan rencana terbaik!'**
  String get ait_plannerEmpty;

  /// No description provided for @ait_plannerExamplesTitle.
  ///
  /// In id, this message translates to:
  /// **'Contoh permintaan:'**
  String get ait_plannerExamplesTitle;

  /// No description provided for @ait_plannerGenerating.
  ///
  /// In id, this message translates to:
  /// **'Membuat rencana perjalanan...'**
  String get ait_plannerGenerating;

  /// No description provided for @ait_plannerHint.
  ///
  /// In id, this message translates to:
  /// **'Deskripsikan rencana liburan impian Anda...'**
  String get ait_plannerHint;

  /// No description provided for @ait_plannerSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan trip: {error}'**
  String ait_plannerSaveFailed(String error);

  /// No description provided for @ait_plannerSaveTrip.
  ///
  /// In id, this message translates to:
  /// **'Simpan Trip ini'**
  String get ait_plannerSaveTrip;

  /// No description provided for @ait_plannerSavedSuccess.
  ///
  /// In id, this message translates to:
  /// **'Trip berhasil disimpan!'**
  String get ait_plannerSavedSuccess;

  /// No description provided for @ait_plannerSavedTooltip.
  ///
  /// In id, this message translates to:
  /// **'Lihat Trip yang Disimpan'**
  String get ait_plannerSavedTooltip;

  /// No description provided for @ait_plannerTitle.
  ///
  /// In id, this message translates to:
  /// **'AI Trip Planner'**
  String get ait_plannerTitle;

  /// No description provided for @ait_pollChangeVote.
  ///
  /// In id, this message translates to:
  /// **'Ganti ke ini'**
  String get ait_pollChangeVote;

  /// No description provided for @ait_pollClosed.
  ///
  /// In id, this message translates to:
  /// **'Closed'**
  String get ait_pollClosed;

  /// No description provided for @ait_pollNotFound.
  ///
  /// In id, this message translates to:
  /// **'Vote tidak ditemukan'**
  String get ait_pollNotFound;

  /// No description provided for @ait_pollOpen.
  ///
  /// In id, this message translates to:
  /// **'Open'**
  String get ait_pollOpen;

  /// No description provided for @ait_pollOptionStats.
  ///
  /// In id, this message translates to:
  /// **'{pct}% • {votes} suara'**
  String ait_pollOptionStats(String pct, num votes);

  /// No description provided for @ait_pollTitle.
  ///
  /// In id, this message translates to:
  /// **'Vote'**
  String get ait_pollTitle;

  /// No description provided for @ait_pollTotalVotes.
  ///
  /// In id, this message translates to:
  /// **'{count} suara'**
  String ait_pollTotalVotes(num count);

  /// No description provided for @ait_pollVoteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memberikan suara'**
  String get ait_pollVoteFailed;

  /// No description provided for @ait_pollVoteNow.
  ///
  /// In id, this message translates to:
  /// **'Vote now'**
  String get ait_pollVoteNow;

  /// No description provided for @ait_pollVoted.
  ///
  /// In id, this message translates to:
  /// **'Suara tercatat'**
  String get ait_pollVoted;

  /// No description provided for @ait_searchAnalyzing.
  ///
  /// In id, this message translates to:
  /// **'🤖 Menganalisis \"{query}\"...'**
  String ait_searchAnalyzing(String query);

  /// No description provided for @ait_searchExamplesTitle.
  ///
  /// In id, this message translates to:
  /// **'Contoh pencarian cerdas:'**
  String get ait_searchExamplesTitle;

  /// No description provided for @ait_searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari dengan bahasa natural...'**
  String get ait_searchHint;

  /// No description provided for @ait_searchResultCount.
  ///
  /// In id, this message translates to:
  /// **'{count} tempat ditemukan'**
  String ait_searchResultCount(num count);

  /// No description provided for @ait_searchTitle.
  ///
  /// In id, this message translates to:
  /// **'Smart Search'**
  String get ait_searchTitle;

  /// No description provided for @ait_taskCreateFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal membuat task'**
  String get ait_taskCreateFailed;

  /// No description provided for @ait_taskDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus task'**
  String get ait_taskDeleteFailed;

  /// No description provided for @ait_taskDetailLabel.
  ///
  /// In id, this message translates to:
  /// **'Detail (opsional)'**
  String get ait_taskDetailLabel;

  /// No description provided for @ait_taskFlight.
  ///
  /// In id, this message translates to:
  /// **'Penerbangan {flightNo}{seats}'**
  String ait_taskFlight(String flightNo, String seats);

  /// No description provided for @ait_taskKindDocument.
  ///
  /// In id, this message translates to:
  /// **'Dokumen'**
  String get ait_taskKindDocument;

  /// No description provided for @ait_taskKindFlight.
  ///
  /// In id, this message translates to:
  /// **'Check-in Penerbangan'**
  String get ait_taskKindFlight;

  /// No description provided for @ait_taskKindLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get ait_taskKindLabel;

  /// No description provided for @ait_taskKindOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get ait_taskKindOther;

  /// No description provided for @ait_taskKindPayment.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get ait_taskKindPayment;

  /// No description provided for @ait_taskKindReminder.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get ait_taskKindReminder;

  /// No description provided for @ait_taskNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Task Baru'**
  String get ait_taskNewTitle;

  /// No description provided for @ait_taskSeats.
  ///
  /// In id, this message translates to:
  /// **' • Kursi: {seats}'**
  String ait_taskSeats(String seats);

  /// No description provided for @ait_taskTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Judul'**
  String get ait_taskTitleLabel;

  /// No description provided for @ait_tasksAllDone.
  ///
  /// In id, this message translates to:
  /// **'Semua task selesai 🎉'**
  String get ait_tasksAllDone;

  /// No description provided for @ait_tasksEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada task'**
  String get ait_tasksEmptyTitle;

  /// No description provided for @ait_tasksHideDone.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan selesai'**
  String get ait_tasksHideDone;

  /// No description provided for @ait_tasksShowDone.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan selesai'**
  String get ait_tasksShowDone;

  /// No description provided for @ait_tasksTitle.
  ///
  /// In id, this message translates to:
  /// **'Travel Tasks'**
  String get ait_tasksTitle;

  /// No description provided for @ait_tripCardBadge.
  ///
  /// In id, this message translates to:
  /// **'TRIP SAVED'**
  String get ait_tripCardBadge;

  /// No description provided for @ait_tripCardDays.
  ///
  /// In id, this message translates to:
  /// **'{count} Hari'**
  String ait_tripCardDays(num count);

  /// No description provided for @ait_tripCardEstimate.
  ///
  /// In id, this message translates to:
  /// **'Est. {cost}'**
  String ait_tripCardEstimate(String cost);

  /// No description provided for @ait_tripDayNumber.
  ///
  /// In id, this message translates to:
  /// **'Day {number}'**
  String ait_tripDayNumber(num number);

  /// No description provided for @ait_tripDeleteTooltip.
  ///
  /// In id, this message translates to:
  /// **'Hapus trip'**
  String get ait_tripDeleteTooltip;

  /// No description provided for @ait_tripDetailBadge.
  ///
  /// In id, this message translates to:
  /// **'TRIP DETAIL'**
  String get ait_tripDetailBadge;

  /// No description provided for @ait_tripDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Trip Detail'**
  String get ait_tripDetailTitle;

  /// No description provided for @ait_tripItineraryTitle.
  ///
  /// In id, this message translates to:
  /// **'Itinerary'**
  String get ait_tripItineraryTitle;

  /// No description provided for @ait_tripNotFound.
  ///
  /// In id, this message translates to:
  /// **'Trip tidak ditemukan'**
  String get ait_tripNotFound;

  /// No description provided for @ait_tripSavedDate.
  ///
  /// In id, this message translates to:
  /// **'Disimpan: {date}'**
  String ait_tripSavedDate(String date);

  /// No description provided for @ait_tripsEmptyCta.
  ///
  /// In id, this message translates to:
  /// **'Buat Itinerary Pertama'**
  String get ait_tripsEmptyCta;

  /// No description provided for @ait_tripsEmptySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Buat itinerary dengan AI lalu simpan untuk keesokan harinya'**
  String get ait_tripsEmptySubtitle;

  /// No description provided for @ait_tripsEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada trip yang disimpan'**
  String get ait_tripsEmptyTitle;

  /// No description provided for @ait_tripsHeaderTitle.
  ///
  /// In id, this message translates to:
  /// **'Trip Anda'**
  String get ait_tripsHeaderTitle;

  /// No description provided for @ait_tripsReloadTooltip.
  ///
  /// In id, this message translates to:
  /// **'Reload trips'**
  String get ait_tripsReloadTooltip;

  /// No description provided for @ait_tripsSavedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} trip disimpan'**
  String ait_tripsSavedCount(num count);

  /// No description provided for @ait_tripsTitle.
  ///
  /// In id, this message translates to:
  /// **'My Trips'**
  String get ait_tripsTitle;

  /// No description provided for @common_create.
  ///
  /// In id, this message translates to:
  /// **'Buat'**
  String get common_create;

  /// No description provided for @common_delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get common_delete;

  /// No description provided for @fun_invoiceButton.
  ///
  /// In id, this message translates to:
  /// **'Invoice'**
  String get fun_invoiceButton;

  /// No description provided for @fun_invoiceNoPdfApp.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan: {path} — tidak ada aplikasi PDF'**
  String fun_invoiceNoPdfApp(String path);

  /// No description provided for @fun_weatherAlertTitle.
  ///
  /// In id, this message translates to:
  /// **'Destination Alert'**
  String get fun_weatherAlertTitle;

  /// No description provided for @fun_weatherCurrentTitle.
  ///
  /// In id, this message translates to:
  /// **'Cuaca Saat Ini'**
  String get fun_weatherCurrentTitle;

  /// No description provided for @fun_policyReschedule.
  ///
  /// In id, this message translates to:
  /// **'Dengan melanjutkan pembayaran, Anda menyetujui harga di atas. Jadwal ulang hanya untuk booking confirmed dan dapat menimbulkan selisih harga; pembatalan mengikuti kebijakan properti.'**
  String get fun_policyReschedule;

  /// No description provided for @fun_plannerDuration.
  ///
  /// In id, this message translates to:
  /// **'Durasi (hari)'**
  String get fun_plannerDuration;

  /// No description provided for @fun_plannerBudget.
  ///
  /// In id, this message translates to:
  /// **'Budget (USD)'**
  String get fun_plannerBudget;

  /// No description provided for @fun_plannerInterests.
  ///
  /// In id, this message translates to:
  /// **'Minat'**
  String get fun_plannerInterests;

  /// No description provided for @fun_plannerGenerate.
  ///
  /// In id, this message translates to:
  /// **'Buatkan Itinerary'**
  String get fun_plannerGenerate;

  /// No description provided for @fun_plannerNeedInterest.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal 1 minat'**
  String get fun_plannerNeedInterest;

  /// No description provided for @fun_plannerInvalidBudget.
  ///
  /// In id, this message translates to:
  /// **'Isi budget dengan angka lebih dari 0'**
  String get fun_plannerInvalidBudget;

  /// No description provided for @fun_interestBeach.
  ///
  /// In id, this message translates to:
  /// **'Pantai'**
  String get fun_interestBeach;

  /// No description provided for @fun_interestCulinary.
  ///
  /// In id, this message translates to:
  /// **'Kuliner'**
  String get fun_interestCulinary;

  /// No description provided for @fun_interestAdventure.
  ///
  /// In id, this message translates to:
  /// **'Petualangan'**
  String get fun_interestAdventure;

  /// No description provided for @fun_interestCulture.
  ///
  /// In id, this message translates to:
  /// **'Budaya'**
  String get fun_interestCulture;

  /// No description provided for @fun_interestIslands.
  ///
  /// In id, this message translates to:
  /// **'Pulau'**
  String get fun_interestIslands;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
