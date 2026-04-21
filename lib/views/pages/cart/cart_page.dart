import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_project/views/pages/cart/provider/cart_provider.dart';
import 'package:ecommerce_project/views/pages/cart/widgets/build_scrollable_sheet.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Column(
          children: [
            Expanded(
              child: cartProvider.items.isEmpty
                  ? const Center(child: Text('Your cart is empty'))
                  : const BuildScrollableSheet(),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Text('Items: ${cartProvider.totalItems}'),
                  const Spacer(),
                  Text(
                    'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
