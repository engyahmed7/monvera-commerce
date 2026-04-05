import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce_project/core/constants/app_constants.dart';
import 'package:ecommerce_project/main.dart';
import 'package:ecommerce_project/providers/auth_provider.dart';
import 'package:ecommerce_project/providers/cart_provider.dart';

void main() {
  testWidgets('Shows splash with app branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Drain splash timer and follow-up async work so no timers are left pending.
    await tester.pump(const Duration(seconds: 2));
    for (var i = 0; i < 20; i++) {
      await tester.pump();
    }
  });
}
