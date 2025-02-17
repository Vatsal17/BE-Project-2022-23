// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBgURKzEZzRyBJmQOS-7JEPStcwXQfU_W4',
    appId: '1:109000356493:web:3e355819b89552c29468c4',
    messagingSenderId: '109000356493',
    projectId: 'major-36e1f',
    authDomain: 'major-36e1f.firebaseapp.com',
    storageBucket: 'major-36e1f.appspot.com',
    measurementId: 'G-NGRZLWYC7Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAz6dJR5gMx63Bu8iREXFGp-tZ5-HS_Okc',
    appId: '1:109000356493:android:fe0f6dff11454ee09468c4',
    messagingSenderId: '109000356493',
    projectId: 'major-36e1f',
    storageBucket: 'major-36e1f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBwSxafcmTdK5yXWv4QrdGpFQvcY8J8Ywc',
    appId: '1:109000356493:ios:9bde7da9343285869468c4',
    messagingSenderId: '109000356493',
    projectId: 'major-36e1f',
    storageBucket: 'major-36e1f.appspot.com',
    iosClientId:
        '109000356493-pmqv81iup7ioit91dbbeqv3coq9vh99s.apps.googleusercontent.com',
    iosBundleId: 'com.example.modernlogintute',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBwSxafcmTdK5yXWv4QrdGpFQvcY8J8Ywc',
    appId: '1:109000356493:ios:9bde7da9343285869468c4',
    messagingSenderId: '109000356493',
    projectId: 'major-36e1f',
    storageBucket: 'major-36e1f.appspot.com',
    iosClientId:
        '109000356493-pmqv81iup7ioit91dbbeqv3coq9vh99s.apps.googleusercontent.com',
    iosBundleId: 'com.example.modernlogintute',
  );
}
