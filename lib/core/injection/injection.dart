import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../services/secure_storage_service.dart';
import '../../features/products/data/repositories/product_repository.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt
    ..registerLazySingleton<SecureStorageService>(
      () => SecureStorageService.instance,
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        ApiClient.instance.dio,
        SecureStorageService.instance,
      ),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(ApiClient.instance.dio),
    )
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(ApiClient.instance.dio),
    )
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(ApiClient.instance.dio),
    )
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(ApiClient.instance.dio),
    );
}