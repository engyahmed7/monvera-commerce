import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_project/providers/products_provider.dart';
import 'package:ecommerce_project/providers/cart_provider.dart';
import 'package:ecommerce_project/views/pages/products/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductsProvider>().loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final provider = context.read<ProductsProvider>();
    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      provider.loadMore();
    }
  }

  double? _parsePrice(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  void _applyFilters(BuildContext context) {
    final minPrice = _parsePrice(_minPriceController.text);
    final maxPrice = _parsePrice(_maxPriceController.text);
    context.read<ProductsProvider>().applyFilters(
      title: _titleController.text,
      category: _categoryController.text,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  void _clearFilters(BuildContext context) {
    _titleController.clear();
    _categoryController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    context.read<ProductsProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, _) {
        return Column(
          children: [
            _FiltersBar(
              titleController: _titleController,
              categoryController: _categoryController,
              minPriceController: _minPriceController,
              maxPriceController: _maxPriceController,
              onApply: () => _applyFilters(context),
              onClear: () => _clearFilters(context),
            ),
            Expanded(child: _buildBody(context, productsProvider)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductsProvider productsProvider) {
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
        controller: _scrollController,
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

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.titleController,
    required this.categoryController,
    required this.minPriceController,
    required this.maxPriceController,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController titleController;
  final TextEditingController categoryController;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Filter by title',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Filter by category slug (e.g. clothes)',
              prefixIcon: Icon(Icons.category),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Min price'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: maxPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Max price'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onApply,
                  child: const Text('Apply filters'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  child: const Text('Clear filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
