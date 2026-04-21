import 'package:flutter/foundation.dart';
import 'package:ecommerce_project/views/pages/cart/model/cart_item_model.dart';
import 'package:ecommerce_project/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, int> _quantitiesByProductId = {};
  final Map<int, ProductModel> _productsById = {};

  Map<int, int> get quantitiesByProductId =>
      Map.unmodifiable(_quantitiesByProductId);

  int get itemTypesCount => _quantitiesByProductId.length;

  int get totalItems => _quantitiesByProductId.values.fold(0, (a, b) => a + b);

  List<CartItemModel> get items {
    final result = <CartItemModel>[];
    _quantitiesByProductId.forEach((productId, quantity) {
      final product = _productsById[productId];
      if (product != null) {
        result.add(CartItemModel(product: product, quantity: quantity));
      }
    });
    // print(result);
    return result;
  }

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

  int getQuantity(int productId) => _quantitiesByProductId[productId] ?? 0;

  void add(ProductModel product) {
    _productsById[product.id] = product;
    _quantitiesByProductId.update(
      product.id,
      (qty) => qty + 1,
      ifAbsent: () => 1,
    );
    print(_quantitiesByProductId);
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
