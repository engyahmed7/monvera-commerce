import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecommerce_project/core/network/dio_client.dart';
import 'package:ecommerce_project/models/product_model.dart';

class ProductsService {
  ProductsService();
  final Dio _dio = DioClient.instance.dio;

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

    final uri = Uri.https('api.escuelajs.co', '/api/v1/products', queryParams);

    final response = await _dio.get<dynamic>(uri.toString());
    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> rawList = data is String
          ? json.decode(data) as List<dynamic>
          : data as List<dynamic>;
      return rawList
          .map(
            (product) => ProductModel.fromJson(product as Map<String, dynamic>),
          )
          .toList();
    }
    throw Exception('Failed to load products (${response.statusCode}).');
  }
}
