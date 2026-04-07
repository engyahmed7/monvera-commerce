import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../views/pages/auth/login_page.dart';
import '../views/pages/cart/cart_page.dart';
import '../views/pages/cart/widgets/cart_card.dart';
import '../views/pages/cart/widgets/build_scrollable_sheet.dart';
import '../views/pages/home/home_page.dart';  
import '../views/pages/profile/profile_page.dart';
import '../providers/cart_provider.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _tabIndex = 0;

  static const List<Widget> _tabPages = [HomePage(), CartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        leading: Image.asset(AppConstants.logoAssetPath),
        actions: [
          if (!auth.isLoggedIn)
            IconButton(
              onPressed: () {
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.login),
              tooltip: 'Login',
            )
          else
            IconButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          IconButton(
            icon: Badge.count(
              count: context.watch<CartProvider>().totalItems,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BuildScrollableSheet();
                },
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _tabIndex, children: _tabPages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
