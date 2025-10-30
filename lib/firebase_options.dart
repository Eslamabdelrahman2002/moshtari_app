import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported in this manual config.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '...from Web config...',
    appId: '...from Web config...',
    projectId: '...from Web config...',
    messagingSenderId: '...from Web config...',
    storageBucket: '...from Web config...',
    authDomain: '...from Web config...',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '...from google-services.json...',
    appId: '...from google-services.json...',
    projectId: '...from google-services.json...',
    messagingSenderId: '...from google-services.json...',
    storageBucket: '...from google-services.json...',
  );
}