/*
"id": 8,
"title": "Classic Red Jogger Sweatpants",
"slug": "classic-red-jogger-sweatpants",
"price": 455,
"description": "Experience ultimate comfort with our red jogger sweatpants, perfect for both workout sessions and lounging around the house. Made with soft, durable fabric, these joggers feature a snug waistband, adjustable drawstring, and practical side pockets for functionality. Their tapered design and elastic cuffs offer a modern fit that keeps you looking stylish on the go.",
"category": {
    "id": 1,
    "name": "Clothes",
    "slug": "clothes",
    "image": "https://i.imgur.com/QkIa5tT.jpeg",
    "creationAt": "2026-04-06T03:15:21.000Z",
    "updatedAt": "2026-04-06T06:40:55.000Z"
},
"images": [
    "https://i.imgur.com/9LFjwpI.jpeg"
],
"creationAt": "2026-04-06T03:15:21.000Z",
"updatedAt": "2026-04-06T11:53:34.000Z"
*/

import 'package:ecommerce_project/models/category_model.dart';

class ProductModel {
  final int id;
  final String title;
  final String slug;
  final double price;
  final String description;
  final CategoryModel category;
  final List<String> images;
  final DateTime creationAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
    required this.creationAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.map((image) => image.toString()).toList()
        : <String>[];
    final rawCategory = json['category'];
    final categoryJson = rawCategory is Map<String, dynamic>
        ? rawCategory
        : <String, dynamic>{};

    // print(ProductModel.fromJson(json));

    return ProductModel(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      price: (json['price'] as num).toDouble(),
      description: (json['description'] ?? '').toString(),
      category: CategoryModel.fromJson(categoryJson),
      images: images,
      creationAt:
          DateTime.tryParse((json['creationAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
