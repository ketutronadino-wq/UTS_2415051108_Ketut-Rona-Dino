import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError('Firebase belum dikonfigurasi. Jalankan: flutterfire configure');
  }
}