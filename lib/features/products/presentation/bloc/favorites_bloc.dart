import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesLoaded extends FavoritesState {
  final Set<int> productIds;

  const FavoritesLoaded(this.productIds);

  @override
  List<Object?> get props => [productIds];

  bool isFavorite(int productId) => productIds.contains(productId);
}

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(const FavoritesLoaded({})) {
    on<FavoriteToggled>(_onToggle);
  }

  void _onToggle(FavoriteToggled event, Emitter<FavoritesState> emit) {
    final current = state as FavoritesLoaded;
    final ids = {...current.productIds};
    if (ids.contains(event.product.id)) {
      ids.remove(event.product.id);
    } else {
      ids.add(event.product.id);
    }
    emit(FavoritesLoaded(ids));
  }

  bool isFavorite(int productId) =>
      state is FavoritesLoaded && (state as FavoritesLoaded).isFavorite(productId);
}