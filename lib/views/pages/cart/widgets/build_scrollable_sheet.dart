import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_project/views/pages/cart/provider/cart_provider.dart';
import 'package:ecommerce_project/views/pages/cart/widgets/cart_card.dart';

class BuildScrollableSheet extends StatelessWidget {
  const BuildScrollableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        if (cartProvider.items.isEmpty) {
          return const Center(child: Text('Your cart is empty'));
        }
        return ListView.builder(
          itemCount: cartProvider.items.length,
          itemBuilder: (context, index) {
            return CartCard(item: cartProvider.items[index]);
          },
        );
      },
    );
  }
}
