import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_project/views/pages/products/provider/products_provider.dart';
import 'package:ecommerce_project/views/pages/home/widgets/home_filters_bar.dart';
import 'package:ecommerce_project/views/pages/home/widgets/home_products_body.dart';

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
            HomeFiltersBar(
              titleController: _titleController,
              categoryController: _categoryController,
              minPriceController: _minPriceController,
              maxPriceController: _maxPriceController,
              onApply: () => _applyFilters(context),
              onClear: () => _clearFilters(context),
            ),
            Expanded(
              child: HomeProductsBody(
                productsProvider: productsProvider,
                scrollController: _scrollController,
              ),
            ),
          ],
        );
      },
    );
  }
}
