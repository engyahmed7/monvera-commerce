import 'dart:convert';

import 'package:ecommerce_project/core/services/storage_service.dart';
import 'package:ecommerce_project/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductsService {
  ProductsService({StorageService? storageService})
: _storage = storageService ?? StorageService();

  final StorageService _storage;

  Future<String?> readStoredToken() => _storage.getToken();

  Future<List<ProductModel>> getProducts({
    int offset = 0,
    int limit = 10,
    String? title,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, String>{
      'offset': offset.toString(),
      'limit': limit.toString(),
    };
    if (title != null && title.trim().isNotEmpty) {
      queryParams['title'] = title.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      queryParams['categorySlug'] = category.trim().toLowerCase();
    }
    if (minPrice != null) {
      queryParams['price_min'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['price_max'] = maxPrice.toString();
    }

    final uri = Uri.https(
      'api.escuelajs.co',
      '/api/v1/products',
      queryParams,
    );

    final token = await readStoredToken();
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((product) => ProductModel.fromJson(product as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load products (${response.statusCode}): ${response.body}',
      );
    }
  }
}
