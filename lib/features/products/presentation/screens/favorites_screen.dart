import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/buttons.dart';
import '../../../../core/widgets/common/state_views.dart';
import '../../domain/entities/product.dart';
import '../bloc/favorites_bloc.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('My Favorites'),
          ],
        ),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          final products =
              state is FavoritesLoaded ? state.products : const <Product>[];
          if (products.isEmpty) {
            return EmptyView(
              title: 'No favorites yet',
              subtitle:
                  'Tap the heart icon on any product and it will be saved '
                  'here for quick access.',
              icon: Icons.favorite_border_rounded,
              action: SizedBox(
                width: 200,
                child: AppOutlinedButton(
                  label: 'Browse Products',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final Product product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}