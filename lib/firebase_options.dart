// ⚠️ PLACEHOLDER — Replace with your actual Firebase configuration
// Run: dart pub global activate flutterfire_cli
//      flutterfire configure
// This will auto-generate the correct values for your Firebase project.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── REPLACE ALL VALUES BELOW WITH YOUR ACTUAL FIREBASE CONFIG ──────────────
  // Get them from: Firebase Console → Project Settings → Your Apps
  // Then run `flutterfire configure` for automatic generation

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',            // ← Replace
    appId: 'YOUR_ANDROID_APP_ID',              // ← Replace
    messagingSenderId: 'YOUR_SENDER_ID',       // ← Replace
    projectId: 'YOUR_PROJECT_ID',             // ← Replace
    storageBucket: 'YOUR_PROJECT_ID.appspot.com', // ← Replace
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',               // ← Replace
    appId: 'YOUR_IOS_APP_ID',                 // ← Replace
    messagingSenderId: 'YOUR_SENDER_ID',      // ← Replace
    projectId: 'YOUR_PROJECT_ID',            // ← Replace
    storageBucket: 'YOUR_PROJECT_ID.appspot.com', // ← Replace
    iosBundleId: 'com.rajmi.movi',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',               // ← Replace
    appId: 'YOUR_WEB_APP_ID',                 // ← Replace
    messagingSenderId: 'YOUR_SENDER_ID',      // ← Replace
    projectId: 'YOUR_PROJECT_ID',            // ← Replace
    storageBucket: 'YOUR_PROJECT_ID.appspot.com', // ← Replace
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com', // ← Replace
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.rajmi.movi',
  );
}
