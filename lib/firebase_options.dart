// Generated-style Firebase options for Flutter Web.
// Replace placeholders by running: flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Default [FirebaseOptions] for the current platform (Web PWA first).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    // Mobile platforms can be added after `flutterfire configure`.
    throw UnsupportedError('Phase 1 targets Flutter Web. Run flutterfire configure.');
  }

  // TODO: paste real values from Firebase Console / flutterfire configure

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAkBElCy_gcVPtsWkmXRMwkcUytrpwiL6I',
    appId: '1:295184626116:web:6f500e49f06c2575e8b491',
    messagingSenderId: '295184626116',
    projectId: 'daily-blocker-app',
    authDomain: 'daily-blocker-app.firebaseapp.com',
    storageBucket: 'daily-blocker-app.firebasestorage.app',
    measurementId: 'G-5SSSTBPB5J',
  );
}
