import 'package:flutter/foundation.dart';
import 'package:ecommerce_project/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, int> _quantitiesByProductId = {};
  final Map<int, ProductModel> _productsById = {};

  Map<int, int> get quantitiesByProductId =>
      Map.unmodifiable(_quantitiesByProductId);

  int get itemTypesCount => _quantitiesByProductId.length;

  int get totalItems => _quantitiesByProductId.values.fold(0, (a, b) => a + b);

  double get totalPrice {
    double total = 0;
    _quantitiesByProductId.forEach((id, qty) {
      final product = _productsById[id];
      if (product != null) {
        total += product.price * qty;
      }
    });
    return total;
  }

  void add(ProductModel product) {
    _productsById[product.id] = product;
    _quantitiesByProductId.update(
      product.id,
      (qty) => qty + 1,
      ifAbsent: () => 1,
    );
    notifyListeners();
  }

  void removeSingle(int productId) {
    final current = _quantitiesByProductId[productId];
    if (current == null) {
      return;
    }
    if (current <= 1) {
      _quantitiesByProductId.remove(productId);
      _productsById.remove(productId);
    } else {
      _quantitiesByProductId[productId] = current - 1;
    }
    notifyListeners();
  }

  void clear() {
    _quantitiesByProductId.clear();
    _productsById.clear();
    notifyListeners();
  }
}
