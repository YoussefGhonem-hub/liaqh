import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyColhQxmZSUYzjAxZz_T_0diIdmpcm5zug',
    appId: '1:201679939264:android:3577ff74b84592de112f25',
    messagingSenderId: '201679939264',
    projectId: 'liaqh-d553c',
    storageBucket: 'liaqh-d553c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyColhQxmZSUYzjAxZz_T_0diIdmpcm5zug',
    appId: '1:201679939264:android:3577ff74b84592de112f25',
    messagingSenderId: '201679939264',
    projectId: 'liaqh-d553c',
    storageBucket: 'liaqh-d553c.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDpH6d_ynhEYjeZnmZnoeESQwpJcBDBi7M',
    appId: '1:201679939264:ios:89f31ba9acdacd0f112f25',
    messagingSenderId: '201679939264',
    projectId: 'liaqh-d553c',
    storageBucket: 'liaqh-d553c.firebasestorage.app',
    iosBundleId: 'com.hypeteq.fitnessapp',
  );
}
