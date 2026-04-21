import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/constants/app_constants.dart';
import 'views/pages/auth/provider/auth_provider.dart';
import 'views/pages/about/provider/about_provider.dart';
import 'views/pages/cart/provider/cart_provider.dart';
import 'views/pages/products/provider/products_provider.dart';
import 'views/pages/auth/login_page.dart';
import 'views/pages/splash/splash_page.dart';
import 'widgets/widget_tree.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    print('Initializing Firebase');
    print(DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  debugPrint(
    'FCM background message: notification=${message.notification != null}, '
    'title=${message.notification?.title}, body=${message.notification?.body}, '
    'data=${message.data}',
  );
}

Future<void> _setupFcmToken() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('FCM notification permission: ${settings.authorizationStatus}');

  final token = await messaging.getToken();
  if (token != null) {
    debugPrint('FCM token: $token');
  } else {
    debugPrint('FCM token is null');
  }

  messaging.onTokenRefresh.listen((newToken) {
    debugPrint('FCM token refreshed: $newToken');
  });

  FirebaseMessaging.onMessage.listen((message) {
    debugPrint(
      'FCM foreground message: notification=${message.notification != null}, '
      'title=${message.notification?.title}, body=${message.notification?.body}, '
      'data=${message.data}',
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint(
      'FCM opened app: notification=${message.notification != null}, '
      'title=${message.notification?.title}, body=${message.notification?.body}, '
      'data=${message.data}',
    );
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _bootstrapFirebase();

  if (firebaseReady) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _setupFcmToken();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AboutProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

Future<bool> _bootstrapFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return true;
  } catch (e, stackTrace) {
    debugPrint('Firebase bootstrap failed: $e');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const WidgetTree(),
      },
    );
  }
}
