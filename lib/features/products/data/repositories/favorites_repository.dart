import 'dart:convert';

import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

class FavoritesRepository {
  final SecureStorageService _storage;

  FavoritesRepository(this._storage);

  Future<List<Product>> getFavorites() async {
    final raw = await _storage.getFavorites();
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFavorites(List<Product> favorites) async {
    final encoded =
        jsonEncode(favorites.map((product) => product.toJson()).toList());
    await _storage.saveFavorites(encoded);
  }
}