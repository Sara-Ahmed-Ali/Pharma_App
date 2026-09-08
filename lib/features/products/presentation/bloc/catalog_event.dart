import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class CatalogFetchRequested extends CatalogEvent {
  final String? search;
  final int? categoryId;

  const CatalogFetchRequested({this.search, this.categoryId});

  @override
  List<Object?> get props => [search, categoryId];
}

class CatalogFilterChanged extends CatalogEvent {
  final String? search;
  final int? categoryId;

  const CatalogFilterChanged({this.search, this.categoryId});

  @override
  List<Object?> get props => [search, categoryId];
}

class CatalogRefreshRequested extends CatalogEvent {
  const CatalogRefreshRequested();
}

class ProductFavoritesToggled extends CatalogEvent {
  final Product product;

  const ProductFavoritesToggled(this.product);

  @override
  List<Object?> get props => [product];
}