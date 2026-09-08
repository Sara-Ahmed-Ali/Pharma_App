import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? search,
    int? categoryId,
  });

  Future<Product> getProductById(int id);

  Future<List<Category>> getCategories();
}