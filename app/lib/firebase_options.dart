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
    projectId: 'classsync-app',
    authDomain: 'classsync-app.firebaseapp.com',
    storageBucket: 'classsync-app.appspot.com',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAvsL-KC2I6Z0axjrV90gs8Xt13khrX4j4',
    appId: '1:214774271726:android:f4a06d8a3b4fb878d9edff',
    messagingSenderId: '214774271726',
    projectId: 'fir-74001',
    storageBucket: 'fir-74001.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy-placeholder',
    appId: '1:1234567890:ios:123456',
    messagingSenderId: '1234567890',
    projectId: 'classsync-app',
    storageBucket: 'classsync-app.appspot.com',
    iosBundleId: 'com.josesfulogabomaderado.classsync',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSy-placeholder',
    appId: '1:1234567890:ios:123456',
    messagingSenderId: '1234567890',
    projectId: 'classsync-app',
    storageBucket: 'classsync-app.appspot.com',
    iosBundleId: 'com.josesfulogabomaderado.classsync',
  );
}