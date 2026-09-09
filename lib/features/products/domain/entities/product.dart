class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final int categoryId;
  final String categoryName;
  final bool isActive;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.categoryId,
    required this.categoryName,
    required this.isActive,
    this.imageUrl,
  });

  bool get inStock => stockQuantity > 0 && isActive;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'isActive': isActive,
        'imageUrl': imageUrl,
      };

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    int? categoryId,
    String? categoryName,
    bool? isActive,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? description;

  const Category({required this.id, required this.name, this.description});
}