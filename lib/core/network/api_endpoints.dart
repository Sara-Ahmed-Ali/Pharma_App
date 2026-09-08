class ApiEndpoints {
  static const String register = '/Auth/register';
  static const String login = '/Auth/login';
  static const String refreshToken = '/Auth/refresh-token';
  static const String me = '/Auth/me';
  static const String users = '/Auth/users';

  static const String products = '/Products';
  static const String categories = '/Categories';

  static const String cart = '/Cart';
  static const String cartAdd = '/Cart/add';
  static const String cartUpdate = '/Cart/update';
  static const String cartClear = '/Cart/clear';

  static String cartRemove(int productId) => '/Cart/remove/$productId';

  static const String orders = '/Orders';
  static const String orderSubmit = '/Orders/submit';
  static String orderById(int id) => '/Orders/$id';
  static String orderCancel(int id) => '/Orders/$id/cancel';

  static const String createPaymentIntent = '/Payments/create-intent';

  static String productsWithFilters({
    String? search,
    int? categoryId,
    bool includeInactive = false,
  }) {
    final params = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (categoryId != null && categoryId > 0) {
      params.add('categoryId=$categoryId');
    }
    if (includeInactive) {
      params.add('includeInactive=true');
    }

    if (params.isEmpty) return products;
    return '$products?${params.join('&')}';
  }

  static String productById(int id) => '/Products/$id';
}
