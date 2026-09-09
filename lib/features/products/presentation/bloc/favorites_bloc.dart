import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/favorites_repository.dart';
import '../../domain/entities/product.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoriteToggled extends FavoritesEvent {
  final Product product;

  const FavoriteToggled(this.product);

  @override
  List<Object?> get props => [product];
}

class FavoritesRequested extends FavoritesEvent {
  const FavoritesRequested();
}

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesLoaded extends FavoritesState {
  final List<Product> products;

  const FavoritesLoaded(this.products);

  @override
  List<Object?> get props => [products];

  bool isFavorite(int productId) => products.any((p) => p.id == productId);
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesBloc(this._repository) : super(const FavoritesLoaded([])) {
    on<FavoriteToggled>(_onToggle);
    on<FavoritesRequested>(_onRestore);
    add(const FavoritesRequested());
  }

  int get favoritesCount {
    final state = this.state;
    return state is FavoritesLoaded ? state.products.length : 0;
  }

  bool isFavorite(int productId) =>
      state is FavoritesLoaded && (state as FavoritesLoaded).isFavorite(productId);

  Future<void> _onRestore(
    FavoritesRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final favorites = await _repository.getFavorites();
    if (isClosed) return;
    emit(FavoritesLoaded(favorites));
  }

  void _onToggle(FavoriteToggled event, Emitter<FavoritesState> emit) {
    final current = state as FavoritesLoaded;
    final favorites = [...current.products];
    if (favorites.any((p) => p.id == event.product.id)) {
      favorites.removeWhere((p) => p.id == event.product.id);
    } else {
      favorites.add(event.product);
    }
    _persist(favorites);
    emit(FavoritesLoaded(favorites));
  }

  void _persist(List<Product> favorites) {
    unawaited(_repository.saveFavorites(favorites));
  }
}