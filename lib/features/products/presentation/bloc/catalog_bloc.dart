import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failures.dart';
import '../../domain/repositories/product_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final ProductRepository _productRepository;

  CatalogBloc(this._productRepository) : super(CatalogInitial()) {
    on<CatalogFetchRequested>(_onFetch);
    on<CatalogFilterChanged>(_onFilterChanged);
    on<CatalogRefreshRequested>(_onRefresh);
  }

  Future<void> _onFetch(
    CatalogFetchRequested event,
    Emitter<CatalogState> emit,
  ) async {
    emit(CatalogLoading());
    try {
      final products = await _productRepository.getProducts(
        search: event.search,
        categoryId: event.categoryId,
      );
      final categories = await _productRepository.getCategories();

      emit(CatalogLoaded(
        products: products,
        categories: categories,
        search: event.search,
        selectedCategoryId: event.categoryId,
      ));
    } catch (e) {
      emit(CatalogError(_messageOf(e)));
    }
  }

  Future<void> _onFilterChanged(
    CatalogFilterChanged event,
    Emitter<CatalogState> emit,
  ) async {
    final current = state;
    if (current is! CatalogLoaded) {
      add(CatalogFetchRequested(
        search: event.search,
        categoryId: event.categoryId,
      ));
      return;
    }

    emit(current.copyWith(
      search: event.search,
      selectedCategoryId: event.categoryId,
      isSearching: true,
    ));

    try {
      final products = await _productRepository.getProducts(
        search: event.search,
        categoryId: event.categoryId,
      );
      if (isClosed) return;
      emit(current.copyWith(
        products: products,
        search: event.search,
        selectedCategoryId: event.categoryId,
        isSearching: false,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(current.copyWith(isSearching: false));
      addError(e);
    }
  }

  Future<void> _onRefresh(
    CatalogRefreshRequested event,
    Emitter<CatalogState> emit,
  ) async {
    final current = state;
    if (current is! CatalogLoaded) {
      add(const CatalogFetchRequested());
      return;
    }

    try {
      final products = await _productRepository.getProducts(
        search: current.search,
        categoryId: current.selectedCategoryId,
      );
      final categories = await _productRepository.getCategories();
      if (isClosed) return;
      emit(current.copyWith(products: products, categories: categories));
    } catch (e) {
      if (isClosed) return;
      addError(e);
    }
  }

  String _messageOf(Object error) {
    if (error is Failure) return error.message;
    if (error is AppException) return error.message;
    return 'An unexpected error occurred.';
  }
}