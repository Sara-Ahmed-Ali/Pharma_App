import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/common/state_views.dart';
import '../../../../core/widgets/shimmers/shimmer_views.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/bloc/catalog_bloc.dart';
import '../../../products/presentation/bloc/catalog_event.dart';
import '../../../products/presentation/bloc/catalog_state.dart';
import '../../../products/presentation/bloc/favorites_bloc.dart';
import '../../../products/presentation/screens/favorites_screen.dart';
import '../../../products/presentation/screens/product_details_screen.dart';
import '../../../products/presentation/widgets/category_chip.dart';
import '../../../products/presentation/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _sliderImages = [
    'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1576602976047-174e57a47881?q=80&w=1200&auto=format&fit=crop',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<CatalogBloc>().add(const CatalogFetchRequested());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<CatalogBloc>().add(
            CatalogFilterChanged(
              search: value.trim(),
              categoryId: _selectedCategoryId,
            ),
          );
    });
  }

  void _onCategorySelected(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    context.read<CatalogBloc>().add(
          CatalogFilterChanged(
            search: _searchController.text.trim(),
            categoryId: categoryId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_pharmacy_rounded,
                color: AppColors.primary, size: 26),
            const SizedBox(width: 8),
            Text(
              'Pharma',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        actions: const [
          _DarkModeButton(),
          _FavoritesButton(),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<CatalogBloc>().add(const CatalogRefreshRequested());
        },
        child: BlocConsumer<CatalogBloc, CatalogState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is CatalogLoading) {
              return const _CatalogLoadingView();
            }

            if (state is CatalogError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ErrorView(
                      message: state.message,
                      onRetry: () {
                        context.read<CatalogBloc>().add(
                              const CatalogFetchRequested(),
                            );
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is CatalogLoaded) {
              final products = state.products;
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BannerSlider(
                          images: _sliderImages,
                          controller: _pageController,
                          currentPage: _currentPage,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                        ),
                        const SizedBox(height: 12),
                        _dotIndicator(
                          _sliderImages.length,
                          _currentPage,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _SearchBar(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              AllChip(
                                isSelected: _selectedCategoryId == null,
                                onTap: () => _onCategorySelected(null),
                              ),
                              const SizedBox(width: 8),
                              ...state.categories.map(
                                (category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CategoryChip(
                                    category: category,
                                    isSelected:
                                        _selectedCategoryId == category.id,
                                    onTap: () =>
                                        _onCategorySelected(category.id),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                products.isEmpty
                                    ? 'No products found'
                                    : '${products.length} products',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              if (state.isSearching)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  if (products.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        title: 'No products available',
                        subtitle: 'Try a different search or category.',
                        icon: Icons.search_off_rounded,
                        action: _buildClearFilters(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => _openProductDetails(product),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildClearFilters() {
    return TextButton(
      onPressed: () {
        _searchController.clear();
        setState(() => _selectedCategoryId = null);
        context.read<CatalogBloc>().add(const CatalogFetchRequested());
      },
      child: const Text('Clear filters'),
    );
  }

  Widget _dotIndicator(int count, int current) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: current == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: current == index ? AppColors.primary : colors.textHint,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _openProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search medicines, supplements...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            isDense: true,
          ),
        );
      },
    );
  }
}

class _BannerSlider extends StatelessWidget {
  final List<String> images;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _BannerSlider({
    required this.images,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 170,
        child: PageView.builder(
          controller: controller,
          itemCount: images.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CatalogLoadingView extends StatelessWidget {
  const _CatalogLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: const [
        SizedBox(height: 8),
        _BannerShimmer(),
        SizedBox(height: 20),
        CategoriesShimmer(),
        SizedBox(height: 16),
        ProductGridShimmer(),
      ],
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _FavoritesButton extends StatelessWidget {
  const _FavoritesButton();

  @override
  Widget build(BuildContext context) {
    final count =
        context.select<FavoritesBloc, int>((bloc) => bloc.favoritesCount);

    return Center(
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FavoritesScreen()),
          );
        },
        tooltip: 'My Favorites',
        icon: Badge.count(
          count: count,
          isLabelVisible: count > 0,
          backgroundColor: AppColors.error,
          child: Icon(
            Icons.favorite_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _DarkModeButton extends StatelessWidget {
  const _DarkModeButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, _, _) {
        final isDark = ThemeController.instance.isDark;
        return Center(
          child: IconButton(
            onPressed: () => ThemeController.instance.toggle(),
            tooltip: isDark ? 'Switch to Light Mode' : 'Dark Mode',
            icon: Icon(
              isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}