// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:sasacation/core/notification_service.dart';
// import 'package:sasacation/core/sasacation_app.dart';
// import 'package:sasacation/firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   await NotificationService.instance.initialize();
 
// void main() {
//    runApp(const LombokApp());
//  }}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sasacation/core/notification_service.dart';
import 'package:sasacation/core/sasacation_app.dart';
import 'package:sasacation/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('>>> 1. Binding initialized');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('>>> 2. Firebase initialized');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  debugPrint('>>> 3. Background handler set');

  await NotificationService.instance.initialize();
  debugPrint('>>> 4. NotificationService initialized');

  runApp(const LombokApp());
  debugPrint('>>> 5. runApp called');
}