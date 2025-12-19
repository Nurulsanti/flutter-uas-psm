class Product {
  final int id;
  final String productId;
  final String productName;
  final String category;
  final String subCategory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.subCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'sub_category': subCategory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
