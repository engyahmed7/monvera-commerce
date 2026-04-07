class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String image;
  final DateTime creationAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    required this.creationAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: ((json['id'] ?? 0) as num).toInt(),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      creationAt:
          DateTime.tryParse((json['creationAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
