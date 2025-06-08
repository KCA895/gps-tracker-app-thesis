import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJrmMrqv1iKItzTiBUQ-obzfgWnqH-A4E',
    appId: '1:974073386160:android:faa359320f7587528f1775',
    messagingSenderId: '974073386160',
    projectId: 'gps-tracker-a09df',
    storageBucket: 'gps-tracker-a09df.appspot.com',
    databaseURL: 'https://gps-tracker-a09df-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
}
