import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_navigation.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/product_images.dart';
import '../../../../core/widgets/common/buttons.dart';
import '../../../../core/widgets/common/state_views.dart';
import '../../../../core/widgets/shimmers/shimmer_views.dart';
import '../../domain/entities/cart.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../orders/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<CartBloc>().add(const CartFetchRequested());
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const CartListShimmer();
          }

          if (state is CartLoaded) {
            final cart = state.cart;
            if (cart.isEmpty) {
              return EmptyView(
                title: 'Your cart is empty',
                subtitle: 'Browse the catalog and add some products.',
                icon: Icons.shopping_cart_outlined,
action: SizedBox(
                  width: 200,
                  child: AppOutlinedButton(
                    label: 'Start Shopping',
                    onPressed: () => mainTabIndex.value = 0,
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<CartBloc>().add(const CartFetchRequested());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _CartItemTile(
                          item: cart.items[index],
                          onRemove: () {
                            context.read<CartBloc>().add(
                                  CartItemRemoved(
                                    cart.items[index].productId,
                                  ),
                                );
                          },
                        );
                      },
                    ),
                  ),
                ),
                _CartSummaryBar(
                  totalPrice: cart.totalPrice,
                  itemsCount: cart.totalItems,
                  onCheckout: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(cart: cart),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;

  const _CartItemTile({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: CachedNetworkImage(
                imageUrl: ProductImages.forProduct(
                  productId: item.productId,
                  categoryName: '',
                ),
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(item.unitPrice),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _CartQtyButton(
                      icon: Icons.remove_rounded,
                      onTap: item.quantity > 1
                          ? () {
                              context.read<CartBloc>().add(
                                    CartItemQuantityUpdated(
                                      productId: item.productId,
                                      quantity: item.quantity - 1,
                                    ),
                                  );
                            }
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _CartQtyButton(
                      icon: Icons.add_rounded,
                      onTap: () {
                        context.read<CartBloc>().add(
                              CartItemQuantityUpdated(
                                productId: item.productId,
                                quantity: item.quantity + 1,
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CartQtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFF1F5F9)
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null
              ? const Color(0xFFCBD5E1)
              : AppColors.primary,
        ),
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final double totalPrice;
  final int itemsCount;
  final VoidCallback onCheckout;

  const _CartSummaryBar({
    required this.totalPrice,
    required this.itemsCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  itemsCount == 1 ? '1 item' : '$itemsCount items',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  Formatters.currency(totalPrice),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Proceed to Checkout',
              icon: Icons.lock_outline,
              onPressed: onCheckout,
            ),
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(const CartCleared());
              },
              child: const Text(
                'Clear Cart',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


