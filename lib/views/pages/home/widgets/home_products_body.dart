import 'package:ecommerce_project/providers/cart_provider.dart';
import 'package:ecommerce_project/providers/products_provider.dart';
import 'package:ecommerce_project/views/pages/products/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeProductsBody extends StatelessWidget {
  const HomeProductsBody({
    super.key,
    required this.productsProvider,
    required this.scrollController,
  });

  final ProductsProvider productsProvider;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (productsProvider.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (productsProvider.errorMessage != null &&
        productsProvider.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            productsProvider.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (productsProvider.products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return RefreshIndicator(
      onRefresh: productsProvider.loadInitial,
      child: ListView.builder(
        controller: scrollController,
        itemCount:
            productsProvider.products.length +
            (productsProvider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= productsProvider.products.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final product = productsProvider.products[index];
          return ProductCard(
            product: product,
            onAddToCart: () {
              context.read<CartProvider>().add(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.title} added to cart')),
              );
            },
          );
        },
      ),
    );
  }
}
