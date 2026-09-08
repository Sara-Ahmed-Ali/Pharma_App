import 'package:dio/dio.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Dio _dio;

  ProductRepositoryImpl(this._dio);

  @override
  Future<List<Product>> getProducts({String? search, int? categoryId}) async {
    return _fetchProducts(search: search, categoryId: categoryId);
  }

  @override
  Future<Product> getProductById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/Products/$id');
    return ProductModel.fromJson(response.data!).toEntity();
  }

  @override
  Future<List<Category>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/Categories');
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map((json) => Category(
              id: (json['id'] as num).toInt(),
              name: json['name'] as String? ?? '',
              description: json['description'] as String?,
            ))
        .toList();
  }

  Future<List<Product>> _fetchProducts({
    String? search,
    int? categoryId,
  }) async {
    try {
      final query = <String, dynamic>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (categoryId != null && categoryId > 0) 'categoryId': categoryId,
      };

      final response = await _dio.get<List<dynamic>>(
        '/Products',
        queryParameters: query,
      );

      return (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Backend returns 404 when there are no matches.
        return [];
      }
      rethrow;
    }
  }
}