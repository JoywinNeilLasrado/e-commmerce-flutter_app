import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_detail_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(productDetailProvider(widget.slug));

    return Scaffold(
      backgroundColor: Colors.white,
      body: detailAsync.when(
        data: (data) => _buildBody(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('Error: $err')),
        ),
      ),
      bottomNavigationBar: detailAsync.when(
        data: (data) => _buildBottomBar(data.product),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildBody(ProductDetailResponse data) {
    final product = data.product;

    return CustomScrollView(
      slivers: [
        // App Bar / Image Gallery
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              child: const BackButton(color: Colors.black),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final isWishlisted = ref
                      .watch(wishlistProvider)
                      .any((p) => p.id == product.id);
                  final authState = ref.watch(authProvider);

                  return CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        if (authState.isAuthenticated) {
                          ref.read(wishlistProvider.notifier).toggle(product);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login to add to wishlist'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [_buildImageGallery(product), _buildImageDots(product)],
            ),
          ),
        ),

        // Product Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand & Condition Badge
                Row(
                  children: [
                    _buildBadge(
                      product.phoneModel?.brand?.name ?? 'Brand',
                      Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(
                      product.condition?.name ?? 'Condition',
                      Colors.teal.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.phoneModel?.name ?? 'Unknown Device',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '₹${product.originalPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      product.stock > 0 ? Icons.check_circle : Icons.error,
                      color: product.stock > 0 ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.stock > 0
                          ? 'In Stock (${product.stock})'
                          : 'Out of Stock',
                      style: TextStyle(
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Specifications
                const Text(
                  'Specifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSpecGrid(product),

                const SizedBox(height: 32),

                // Description
                const Text(
                  'About this device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description ??
                      'No description available for this device.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                // Features / Specs placeholders
                _buildInfoTile(
                  Icons.verified,
                  '12-Month Warranty',
                  'Certified by our experts',
                ),
                _buildInfoTile(
                  Icons.local_shipping,
                  'Free Delivery',
                  'Within 2-4 business days',
                ),
                _buildInfoTile(
                  Icons.assignment_return,
                  '7-Day Replacement',
                  'Easy doorstep returns',
                ),

                const SizedBox(height: 48),

                // Related Products
                if (data.relatedProducts.isNotEmpty) ...[
                  const Text(
                    'You might also like',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.relatedProducts.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 180,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: ProductCard(
                              product: data.relatedProducts[index],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(Product product) {
    final images = product.images.isEmpty
        ? [product.imageUrl]
        : product.images.map((e) => e.fullUrl).toList();

    return PageView.builder(
      onPageChanged: (index) => setState(() => _currentImageIndex = index),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, err) => const Icon(
                Icons.phone_android,
                size: 100,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageDots(Product product) {
    final count = product.images.isEmpty ? 1 : product.images.length;
    if (count <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: _currentImageIndex == index ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentImageIndex == index
                  ? Colors.blue
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecGrid(Product product) {
    if (product.phoneModel == null) return const SizedBox.shrink();
    final model = product.phoneModel!;

    final specs = [
      if (model.displaySize != null)
        {
          'label': 'Display',
          'value': model.displaySize!,
          'icon': Icons.screenshot,
        },
      if (model.processor != null)
        {'label': 'Processor', 'value': model.processor!, 'icon': Icons.memory},
      if (model.ram != null)
        {'label': 'RAM', 'value': model.ram!, 'icon': Icons.speed},
      if (model.camera != null)
        {'label': 'Camera', 'value': model.camera!, 'icon': Icons.camera_alt},
      if (model.battery != null)
        {
          'label': 'Battery',
          'value': model.battery!,
          'icon': Icons.battery_charging_full,
        },
      if (model.os != null)
        {'label': 'OS', 'value': model.os!, 'icon': Icons.android},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(
                spec['icon'] as IconData,
                size: 20,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      spec['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      spec['value'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
