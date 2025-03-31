// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyDxz0D8sxraH3gNkyd5iWe6wd6Y9CMrK2k',
    appId: '1:523829422600:web:7335dff02272aeffee7fbd',
    messagingSenderId: '523829422600',
    projectId: 'subtle-creek-419518',
    authDomain: 'subtle-creek-419518.firebaseapp.com',
    storageBucket: 'subtle-creek-419518.firebasestorage.app',
    measurementId: 'G-18YGE1GH5S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBN1seGpPoFXjI-4KHaRX57AMacQMvXuIY',
    appId: '1:523829422600:android:065a31c7880724aeee7fbd',
    messagingSenderId: '523829422600',
    projectId: 'subtle-creek-419518',
    storageBucket: 'subtle-creek-419518.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANVFEc11eL2ohereL4Lm7qxwBw0bwNg7Q',
    appId: '1:523829422600:ios:2bd3314bd8da9dafee7fbd',
    messagingSenderId: '523829422600',
    projectId: 'subtle-creek-419518',
    storageBucket: 'subtle-creek-419518.firebasestorage.app',
    androidClientId: '523829422600-auhkv3j10cpcv4lfj8sli4g69bao16is.apps.googleusercontent.com',
    iosClientId: '523829422600-fuqo3snb72ol268euqfqkt5eio6qgomf.apps.googleusercontent.com',
    iosBundleId: 'com.sarankar.chessearn',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANVFEc11eL2ohereL4Lm7qxwBw0bwNg7Q',
    appId: '1:523829422600:ios:5a613b00dd944e78ee7fbd',
    messagingSenderId: '523829422600',
    projectId: 'subtle-creek-419518',
    storageBucket: 'subtle-creek-419518.firebasestorage.app',
    androidClientId: '523829422600-auhkv3j10cpcv4lfj8sli4g69bao16is.apps.googleusercontent.com',
    iosClientId: '523829422600-gb9be9hpg4n89uvjrl8p2q00pj2m4ho6.apps.googleusercontent.com',
    iosBundleId: 'com.example.chessOnline',
  );

}