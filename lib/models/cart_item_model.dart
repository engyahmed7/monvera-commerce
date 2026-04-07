import 'package:ecommerce_project/models/product_model.dart';

class CartItemModel {
  const CartItemModel({required this.product, required this.quantity});

  final ProductModel product;
  final int quantity;
}
