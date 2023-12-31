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
    apiKey: 'AIzaSyCIr6sLQ3tvF1_Qt7Ka_Imp1FYkIfp3Bb4',
    appId: '1:260721064297:web:3846d0ad8d75b8175b65f8',
    messagingSenderId: '260721064297',
    projectId: 'attendance-inn',
    authDomain: 'attendance-inn.firebaseapp.com',
    storageBucket: 'attendance-inn.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnuRiztHm1FGzvCJSBaHlZgzenZa4oLBE',
    appId: '1:260721064297:android:4b3b2f45eb0c70c35b65f8',
    messagingSenderId: '260721064297',
    projectId: 'attendance-inn',
    storageBucket: 'attendance-inn.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdsyh5cDxMkRuV_ZpSzjLjJWmXgkG2vF8',
    appId: '1:260721064297:ios:0922d8b5f7ee3bc05b65f8',
    messagingSenderId: '260721064297',
    projectId: 'attendance-inn',
    storageBucket: 'attendance-inn.appspot.com',
    iosBundleId: 'com.example.attendanceIn',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDdsyh5cDxMkRuV_ZpSzjLjJWmXgkG2vF8',
    appId: '1:260721064297:ios:c368445bc84a71a45b65f8',
    messagingSenderId: '260721064297',
    projectId: 'attendance-inn',
    storageBucket: 'attendance-inn.appspot.com',
    iosBundleId: 'com.example.attendanceIn.RunnerTests',
  );
}
