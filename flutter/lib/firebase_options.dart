// Firebase configuration for web
// Generated from Firebase Console

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
        return windows;
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

  // Web configuration - using your existing Firebase project
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAIxJ1XU2JxIV_aRDPgyY7WtjQ_EiSvIpE',
    appId: '1:YOUR_APP_ID:web:YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'chatbot-cec24',
    authDomain: 'chatbot-cec24.firebaseapp.com',
    databaseURL: 'https://chatbot-cec24-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatbot-cec24.appspot.com',
  );

  // Android configuration placeholder
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIxJ1XU2JxIV_aRDPgyY7WtjQ_EiSvIpE',
    appId: '1:YOUR_APP_ID:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'chatbot-cec24',
    databaseURL: 'https://chatbot-cec24-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatbot-cec24.appspot.com',
  );

  // iOS configuration placeholder
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIxJ1XU2JxIV_aRDPgyY7WtjQ_EiSvIpE',
    appId: '1:YOUR_APP_ID:ios:YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'chatbot-cec24',
    databaseURL: 'https://chatbot-cec24-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatbot-cec24.appspot.com',
    iosBundleId: 'com.example.chatbotFlutter',
  );

  // macOS configuration placeholder
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAIxJ1XU2JxIV_aRDPgyY7WtjQ_EiSvIpE',
    appId: '1:YOUR_APP_ID:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'chatbot-cec24',
    databaseURL: 'https://chatbot-cec24-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatbot-cec24.appspot.com',
    iosBundleId: 'com.example.chatbotFlutter',
  );

  // Windows configuration placeholder
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAIxJ1XU2JxIV_aRDPgyY7WtjQ_EiSvIpE',
    appId: '1:YOUR_APP_ID:web:YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'chatbot-cec24',
    authDomain: 'chatbot-cec24.firebaseapp.com',
    databaseURL: 'https://chatbot-cec24-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatbot-cec24.appspot.com',
  );
}
