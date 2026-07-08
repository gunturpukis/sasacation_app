import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/repo/notification_repository.dart';

/// Handler untuk pesan FCM yang datang saat app di background/terminated.
/// HARUS berupa top-level function (bukan method di dalam class), ini
/// syarat dari firebase_messaging supaya bisa dijalankan di isolate terpisah.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase.initializeApp() dipanggil ulang di sini karena background
  // handler berjalan di isolate baru yang belum ter-inisialisasi.
  // (import langsung tanpa circular dependency ke main.dart)
  debugPrint('📩 [Background] Notifikasi diterima: ${message.notification?.title}');
}

/// Mengelola seluruh siklus push notification:
/// - Minta izin notifikasi (Android 13+/iOS)
/// - Ambil & simpan FCM token, kirim ke backend
/// - Tampilkan notifikasi lokal ketika app sedang dibuka (foreground)
/// - Handle ketika user tap notifikasi
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationRepository _repository = NotificationRepository();

  static const _androidChannel = AndroidNotificationChannel(
    'sasacation_default',
    'Sasacation Notifications',
    description: 'Notifikasi booking, promo, dan info penting Sasacation',
    importance: Importance.high,
  );

  bool _initialized = false;

  /// Panggil sekali saat app start (setelah Firebase.initializeApp),
  /// dan panggil lagi setelah login berhasil supaya token langsung
  /// terdaftar ke akun yang benar.
  Future<void> initialize({bool registerTokenToBackend = false}) async {
    if (!_initialized) {
      await _requestPermission();
      await _setupLocalNotifications();
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);
      _messaging.onTokenRefresh.listen((newToken) {
        if (registerTokenToBackend) _repository.registerToken(newToken);
      });
      _initialized = true;
    }

    if (registerTokenToBackend) {
      await registerCurrentToken();
    }
  }

  /// Ambil FCM token perangkat saat ini dan kirim ke backend.
  /// Panggil ini setelah user berhasil login.
  Future<void> registerCurrentToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _repository.registerToken(token);
    }
  }

  /// Panggil saat logout supaya device berhenti menerima push untuk akun ini.
  Future<void> unregisterToken() async {
    await _repository.unregisterToken();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  /// Saat app sedang dibuka (foreground), FCM tidak otomatis menampilkan
  /// notifikasi system tray — jadi kita tampilkan manual lewat local
  /// notifications supaya UX-nya konsisten dengan saat app di background.
  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  void _onNotificationTap(RemoteMessage message) {
    // TODO: Arahkan ke halaman terkait berdasarkan message.data,
    // misalnya ke detail booking: message.data['bookingId'].
    debugPrint('🔔 Notifikasi ditap, data: ${message.data}');
  }
}
