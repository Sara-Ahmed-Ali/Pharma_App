import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/product_images.dart';
import '../../../../core/widgets/common/buttons.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../domain/entities/product.dart';
import '../bloc/favorites_bloc.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  bool _addedToCart = false;

  bool get _inStock => widget.product.inStock;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isFavorite =
        context.watch<FavoritesBloc>().isFavorite(product.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  context.read<FavoritesBloc>().add(FavoriteToggled(product));
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: ProductImages.forProduct(
                  productId: product.id,
                  categoryName: product.categoryName,
                ),
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(
                      Icons.medication_outlined,
                      color: Color(0xFFCBD5E1),
                      size: 64,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Color(0xFFCBD5E1),
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Formatters.currency(product.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.categoryName,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StockBadge(inStock: _inStock),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_inStock) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _QuantitySelector(
                      quantity: _quantity,
                      max: product.stockQuantity,
                      onChanged: (value) {
                        setState(() => _quantity = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${product.stockQuantity} items in stock',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: _inStock
              ? (_addedToCart ? 'Added to Cart ✓' : 'Add to Cart')
              : 'Out of Stock',
          icon: _inStock ? Icons.shopping_cart_outlined : null,
          onPressed: _inStock ? _addToCart : null,
        ),
      ),
    );
  }

  void _addToCart() {
    context.read<CartBloc>().add(
          CartItemAdded(productId: widget.product.id, quantity: _quantity),
        );
    setState(() => _addedToCart = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to your cart'),
        backgroundColor: AppColors.success,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _addedToCart = false);
    });
  }
}

class _StockBadge extends StatelessWidget {
  final bool inStock;

  const _StockBadge({required this.inStock});

  @override
  Widget build(BuildContext context) {
    return Text(
      inStock ? 'In Stock' : 'Out of Stock',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: inStock ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyButton(
          icon: Icons.remove_rounded,
          onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
        ),
        const SizedBox(width: 16),
        Text(
          '$quantity',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        _QtyButton(
          icon: Icons.add_rounded,
          onTap: quantity < max ? () => onChanged(quantity + 1) : null,
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFF1F5F9)
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null
              ? const Color(0xFFCBD5E1)
              : AppColors.primary,
        ),
      ),
    );
  }
}


