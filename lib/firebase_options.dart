import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const String _firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
  );
  static const String _firebaseAppIdAndroid = String.fromEnvironment(
    'FIREBASE_APP_ID_ANDROID',
  );
  static const String _firebaseAppIdIos = String.fromEnvironment(
    'FIREBASE_APP_ID_IOS',
  );
  static const String _firebaseAppIdWeb = String.fromEnvironment(
    'FIREBASE_APP_ID_WEB',
  );
  static const String _firebaseAppIdMacos = String.fromEnvironment(
    'FIREBASE_APP_ID_MACOS',
  );
  static const String _firebaseAppIdWindows = String.fromEnvironment(
    'FIREBASE_APP_ID_WINDOWS',
  );
  static const String _firebaseAppIdLinux = String.fromEnvironment(
    'FIREBASE_APP_ID_LINUX',
  );
  static const String _firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String _firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const String _firebaseDatabaseUrl = String.fromEnvironment(
    'FIREBASE_DATABASE_URL',
  );
  static const String _firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const String _firebaseIosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );
  static const String _firebaseMacosBundleId = String.fromEnvironment(
    'FIREBASE_MACOS_BUNDLE_ID',
  );

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
        return linux;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '$defaultTargetPlatform.',
        );
    }
  }

  static String _required(String key, String value) {
    if (value.isEmpty) {
      throw StateError(
        'Missing Firebase config: $key. '
        'Provide it with --dart-define=$key=VALUE',
      );
    }
    return value;
  }

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: _required('FIREBASE_API_KEY', _firebaseApiKey),
    appId: _required('FIREBASE_APP_ID_WEB', _firebaseAppIdWeb),
    messagingSenderId: _required(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _required('FIREBASE_PROJECT_ID', _firebaseProjectId),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
    databaseURL: _required('FIREBASE_DATABASE_URL', _firebaseDatabaseUrl),
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: _required('FIREBASE_API_KEY', _firebaseApiKey),
    appId: _required('FIREBASE_APP_ID_ANDROID', _firebaseAppIdAndroid),
    messagingSenderId: _required(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _required('FIREBASE_PROJECT_ID', _firebaseProjectId),
    databaseURL: _required('FIREBASE_DATABASE_URL', _firebaseDatabaseUrl),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: _required('FIREBASE_API_KEY', _firebaseApiKey),
    appId: _required('FIREBASE_APP_ID_IOS', _firebaseAppIdIos),
    messagingSenderId: _required(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _required('FIREBASE_PROJECT_ID', _firebaseProjectId),
    databaseURL: _required('FIREBASE_DATABASE_URL', _firebaseDatabaseUrl),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
    iosBundleId: _required('FIREBASE_IOS_BUNDLE_ID', _firebaseIosBundleId),
  );

  static final FirebaseOptions macos = FirebaseOptions(
    apiKey: _required('FIREBASE_API_KEY', _firebaseApiKey),
    appId: _required('FIREBASE_APP_ID_MACOS', _firebaseAppIdMacos),
    messagingSenderId: _required(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _required('FIREBASE_PROJECT_ID', _firebaseProjectId),
    databaseURL: _required('FIREBASE_DATABASE_URL', _firebaseDatabaseUrl),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
    iosBundleId: _required('FIREBASE_MACOS_BUNDLE_ID', _firebaseMacosBundleId),
  );

  static final FirebaseOptions windows = FirebaseOptions(
    apiKey: _required('FIREBASE_API_KEY', _firebaseApiKey),
    appId: _required('FIREBASE_APP_ID_WINDOWS', _firebaseAppIdWindows),
    messagingSenderId: _required(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _required('FIREBASE_PROJECT_ID', _firebaseProjectId),
    databaseURL: _required('FIREBASE_DATABASE_URL', _firebaseDatabaseUrl),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
  );

  static final FirebaseOptions linux = FirebaseOptions(
    apiKey: _required('FIREBASE_API_KEY', _firebaseApiKey),
    appId: _required('FIREBASE_APP_ID_LINUX', _firebaseAppIdLinux),
    messagingSenderId: _required(
      'FIREBASE_MESSAGING_SENDER_ID',
      _firebaseMessagingSenderId,
    ),
    projectId: _required('FIREBASE_PROJECT_ID', _firebaseProjectId),
    databaseURL: _required('FIREBASE_DATABASE_URL', _firebaseDatabaseUrl),
    storageBucket: _required('FIREBASE_STORAGE_BUCKET', _firebaseStorageBucket),
  );

}
