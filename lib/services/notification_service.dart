import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../firebase_options.dart';
import 'database_guard.dart';

typedef ForegroundMessageCallback = void Function(String title, String body);
typedef TokenCallback = void Function(String token);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[BACKGROUND] ${message.notification?.title}');
}

class NotificationService {
  static bool isFirebaseReady = false;

  static Future<bool> initializeFirebase() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      isFirebaseReady = true;
    } catch (e) {
      isFirebaseReady = false;
      debugPrint('Firebase belum siap: $e');
    }
    return isFirebaseReady;
  }

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenSubscription;

  Future<String> requestPermission() async {
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    return settings.authorizationStatus.name;
  }

  Future<void> enableForegroundPresentation() {
    return _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  Future<String?> getToken() async {
    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    return token;
  }

  Future<void> saveTokenToSupabase(String token) {
    return guardDatabase(() async {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;
      await client.from('device_tokens').upsert({
        'token': token,
        'user_id': user.id,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    });
  }

  Future<void> deleteTokenFromSupabase(String token) {
    return guardDatabase(() async {
      await Supabase.instance.client.from('device_tokens').delete().eq('token', token);
    });
  }

  void startListening({
    required ForegroundMessageCallback onForeground,
    required TokenCallback onTokenRefresh,
  }) {
    stopListening();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onForeground(message.notification?.title ?? 'Notifikasi', message.notification?.body ?? '');
    });
    // ignore: deprecated_member_use
    _tokenSubscription = _messaging.onTokenRefresh.listen(onTokenRefresh);
  }

  void stopListening() {
    _foregroundSubscription?.cancel();
    _tokenSubscription?.cancel();
    _foregroundSubscription = null;
    _tokenSubscription = null;
  }
}