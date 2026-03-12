import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../models/brand.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'PhoneShop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: Badge(
              label: Text(ref.watch(cartProvider).maybeWhen(
                data: (cart) => cart.items.length.toString(),
                orElse: () => '0',
              )),
              isLabelVisible: ref.watch(cartProvider).maybeWhen(
                data: (cart) => cart.items.isNotEmpty,
                orElse: () => false,
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => context.push('/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: homeDataAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(homeDataProvider),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                _buildBrandsSection(data.brands),
                _buildTrendingSection(data.featuredProducts),
                _buildWhyUsSection(),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load data: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(homeDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  'CERTIFIED REFURBISHED',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Premium Tech.\nSmart Prices.',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Experience the device you\'ve always wanted at a fraction of the cost. 12-month warranty included.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Shop Collection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsSection(List<Brand> brands) {
    if (brands.isEmpty) return const SizedBox.shrink();
    return _AutoScrollBrands(brands: brands);
  }

  Widget _buildTrendingSection(List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HANDPICKED FOR YOU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              letterSpacing: 1.5,
            ),
          ),
          const Text(
            'Trending Now',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  context.push('/products/${product.slug}');
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWhyUsSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEFF7F6),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Us',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildFeatureRow(
            Icons.price_check,
            'Best Prices',
            'Objective AI-based pricing.',
          ),
          _buildFeatureRow(
            Icons.bolt,
            'Instant Payment',
            'Instant Money Transfer at pickup.',
          ),
          _buildFeatureRow(
            Icons.local_shipping,
            'Free Doorstep Pickup',
            'No fees for pickup across India.',
          ),
          _buildFeatureRow(
            Icons.verified_user,
            'Data Security',
            'Factory Grade Data Wipe Guaranteed.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade600, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoScrollBrands extends StatefulWidget {
  final List<Brand> brands;

  const _AutoScrollBrands({required this.brands});

  @override
  State<_AutoScrollBrands> createState() => _AutoScrollBrandsState();
}

class _AutoScrollBrandsState extends State<_AutoScrollBrands> {
  final ScrollController _scrollController = ScrollController();
  bool _isAutoScrolling = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  Future<void> _startAutoScroll() async {
    await Future.delayed(const Duration(seconds: 1)); // initial delay
    while (_isAutoScrolling && mounted) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;

        if (maxScroll > 0) {
          if (currentScroll >= maxScroll - 5) {
            // Reached the end
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) _scrollController.jumpTo(0);
          } else {
            await _scrollController.animateTo(
              currentScroll + 30, // move by 30 pixels
              duration: const Duration(
                milliseconds: 1000,
              ), // smooth 1 second animation
              curve: Curves.linear,
            );
          }
        } else {
          await Future.delayed(const Duration(seconds: 1));
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void dispose() {
    _isAutoScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Top Selling Brands',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.brands.length,
              itemBuilder: (context, index) {
                final brand = widget.brands[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: brand.logoPath != null
                              ? Image.network(
                                  brand.logoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                )
                              : const Icon(
                                  Icons.smartphone,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          brand.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
