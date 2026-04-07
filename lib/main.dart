import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/products_provider.dart';
import 'views/pages/auth/login_page.dart';
import 'views/pages/splash/splash_page.dart';
import 'widgets/widget_tree.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
      ],
      child: MyApp(),
    ),
  );
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
