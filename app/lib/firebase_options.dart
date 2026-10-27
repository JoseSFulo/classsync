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
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSy-placeholder',
    appId: '1:1234567890:web:123456',
    messagingSenderId: '1234567890',
    projectId: 'classsync-42ed6',
    authDomain: 'classsync-app.firebaseapp.com',
    storageBucket: 'classsync-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCAhYvkUiSrw3TYQRA4O2I0aOPcObRLBQY',
    appId: '1:123599252272:android:566e469806c147f4ba76f5',
    messagingSenderId: '123599252272',
    projectId: 'classsync-42ed6',
    storageBucket: 'classsync-42ed6.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDp_zoMF2zenbtCoWXwsk40UgS2F4_Yj9Q',
    appId: '1:123599252272:ios:e7fd0108eab805a9ba76f5',
    messagingSenderId: '123599252272',
    projectId: 'classsync-42ed6',
    storageBucket: 'classsync-42ed6.firebasestorage.app',
    iosClientId:
        '123599252272-ktpbhniiprfelfischhalthsign97ds9.apps.googleusercontent.com',
    iosBundleId: 'com.josesfulogabomaderado.classsync',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSy-placeholder',
    appId: '1:1234567890:ios:123456',
    messagingSenderId: '1234567890',
    projectId: 'classsync-42ed6',
    storageBucket: 'classsync-app.appspot.com',
    iosBundleId: 'com.josesfulogabomaderado.classsync',
  );
}
