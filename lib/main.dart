import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'core/constants/app_constants.dart';
import 'core/realtime/reverb_provider.dart';
import 'core/services/fcm_token_service.dart';
import 'views/pages/auth/provider/auth_provider.dart';
import 'views/pages/about/provider/about_provider.dart';
import 'views/pages/cart/provider/cart_provider.dart';
import 'views/pages/products/provider/products_provider.dart';
import 'views/pages/chat/provider/chat_provider.dart';
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

void _setupFcmListeners() {
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
    _setupFcmListeners();
    FcmTokenService.setupAfterFirstFrame();
  } else {
    debugPrint(
      '[FCM] Skipped device token — Firebase did not initialize. '
      'Check firebase_options / google-services.json / GoogleService-Info.plist.',
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AboutProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => ReverbProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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
    debugPrint(
      'Run with: flutter run --dart-define-from-file=env/dev.json '
      '(create env/dev.json from env/dev.example.json + google-services.json)',
    );
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _buildAnimatedRoute(
          settings: settings,
          page: const LoginPage(),
        );
      case '/home':
        return _buildAnimatedRoute(
          settings: settings,
          page: const WidgetTree(),
        );
      default:
        return null;
    }
  }

  PageRouteBuilder<dynamic> _buildAnimatedRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
    );
  }

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
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
