import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service = NotificationService();

  static Future<bool> initializeFirebase() => NotificationService.initializeFirebase();
  static bool get isFirebaseReady => NotificationService.isFirebaseReady;

  Future<String> requestPermission() => _service.requestPermission();
  Future<void> enableForegroundPresentation() => _service.enableForegroundPresentation();
  Future<String?> getToken() => _service.getToken();
  Future<void> registerToken(String token) => _service.saveTokenToSupabase(token);
  Future<void> unregisterToken(String token) => _service.deleteTokenFromSupabase(token);

  void startListening({required ForegroundMessageCallback onForeground, required TokenCallback onTokenRefresh}) {
    _service.startListening(onForeground: onForeground, onTokenRefresh: onTokenRefresh);
  }
  void stopListening() => _service.stopListening();
}