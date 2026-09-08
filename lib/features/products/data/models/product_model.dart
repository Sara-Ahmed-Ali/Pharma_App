import '../../domain/entities/product.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final int categoryId;
  final String categoryName;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.categoryId,
    required this.categoryName,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Product toEntity() => Product(
        id: id,
        name: name,
        description: description,
        price: price,
        stockQuantity: stockQuantity,
        categoryId: categoryId,
        categoryName: categoryName,
        isActive: isActive,
      );
}