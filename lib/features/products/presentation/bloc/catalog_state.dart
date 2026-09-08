import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<Product> products;
  final List<Category> categories;
  final String? search;
  final int? selectedCategoryId;
  final bool isSearching;

  const CatalogLoaded({
    required this.products,
    required this.categories,
    this.search,
    this.selectedCategoryId,
    this.isSearching = false,
  });

  CatalogLoaded copyWith({
    List<Product>? products,
    List<Category>? categories,
    String? search,
    int? selectedCategoryId,
    bool? isSearching,
  }) {
    return CatalogLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      search: search ?? this.search,
      selectedCategoryId:
          selectedCategoryId ?? this.selectedCategoryId,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        products,
        categories,
        search,
        selectedCategoryId,
        isSearching,
      ];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}