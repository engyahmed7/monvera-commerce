import 'package:flutter/material.dart';
import 'package:ecommerce_project/models/product_model.dart';
import 'package:ecommerce_project/core/services/apis/products_service.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider({ProductsService? productsService})
    : _productsService = productsService ?? ProductsService();

  final ProductsService _productsService;

  final List<ProductModel> _products = [];
  
  final int _limit = 10;
  int _offset = 0;
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  String _titleFilter = '';
  String _categoryFilter = '';
  double? _minPriceFilter;
  double? _maxPriceFilter;

  List<ProductModel> get products => List.unmodifiable(_products);


  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String get titleFilter => _titleFilter;
  String get categoryFilter => _categoryFilter;
  double? get minPriceFilter => _minPriceFilter;
  double? get maxPriceFilter => _maxPriceFilter;

  Future<void> loadInitial() async {
    _offset = 0;
    _hasMore = true;
    _errorMessage = null;
    _isInitialLoading = true;
    _products.clear();
    notifyListeners();

    try {
      final page = await _productsService.getProducts(
        offset: _offset,
        limit: _limit,
        title: _titleFilter,
        category: _categoryFilter,
        minPrice: _minPriceFilter,
        maxPrice: _maxPriceFilter,
      );
      _products.addAll(page);
      _offset += page.length;
      _hasMore = page.length == _limit;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isInitialLoading || _isLoadingMore || !_hasMore) {
      return;
    }
    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _productsService.getProducts(
        offset: _offset,
        limit: _limit,
        title: _titleFilter,
        category: _categoryFilter,
        minPrice: _minPriceFilter,
        maxPrice: _maxPriceFilter,
      );
      _products.addAll(page);
      _offset += page.length;
      _hasMore = page.length == _limit;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    String? title,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    _titleFilter = (title ?? '').trim();
    _categoryFilter = (category ?? '').trim();
    _minPriceFilter = minPrice;
    _maxPriceFilter = maxPrice;
    await loadInitial();
  }

  Future<void> clearFilters() async {
    _titleFilter = '';
    _categoryFilter = '';
    _minPriceFilter = null;
    _maxPriceFilter = null;
    await loadInitial();
  }
}
