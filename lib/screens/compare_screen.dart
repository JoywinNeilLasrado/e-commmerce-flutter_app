import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/compare_provider.dart';
import '../models/product.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareAsync = ref.watch(compareDataProvider);
    final idsNotifier = ref.read(compareIdsProvider.notifier);
    final selectedIds = ref.watch(compareIdsProvider).ids;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAFE), // Light blue app background
      appBar: AppBar(
        title: const Text(
          'Compare Products',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFF0FAFE),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: () => idsNotifier.clear(),
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFF0D6EFD)),
            ),
          ),
        ],
      ),
      body: compareAsync.when(
        data: (data) => _buildBody(context, ref, data, selectedIds),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    CompareResponse data,
    List<int> selectedIds,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compare Phones',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B2230),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select up to 3 phones to compare specs and prices.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Selection Dropdowns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: List.generate(3, (index) {
                final isSelected = index < selectedIds.length;
                final productId = isSelected ? selectedIds[index] : null;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'PHONE ${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: productId,
                              hint: Text(
                                '— Select a phone —',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              items: data.allProducts
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(
                                        p.title,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  if (isSelected) {
                                    ref
                                        .read(compareIdsProvider.notifier)
                                        .removeId(productId!);
                                  }
                                  ref
                                      .read(compareIdsProvider.notifier)
                                      .addId(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // Comparison Table
          if (data.compareProducts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Add at least one product to start comparing.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Row: Specs label + Products Cards
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              bottom: 24,
                            ),
                            child: Text(
                              'SPECS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        ...data.compareProducts.map(
                          (p) => Expanded(child: _buildProductHeader(p)),
                        ),
                      ],
                    ),

                    // Pricing Section Header
                    _buildSectionHeader('PRICING'),

                    _buildTableRow(
                      'Starting Price',
                      Icons.local_offer_outlined,
                      data,
                      (p) => '₹${p.price.toStringAsFixed(0)}',
                    ),
                    _buildTableRow(
                      'Storage Options',
                      Icons.sd_storage_outlined,
                      data,
                      (p) => _parseStorage(p.title),
                    ),
                    _buildTableRow(
                      'Colors',
                      Icons.color_lens_outlined,
                      data,
                      (p) => _parseColor(p.title),
                    ),
                    _buildTableRow(
                      'Condition',
                      Icons.star_border_outlined,
                      data,
                      (p) => p.condition?.name ?? '-',
                    ),
                    _buildTableRow(
                      'In Stock',
                      Icons.check_circle_outline,
                      data,
                      (p) => p.stock > 0 ? 'In Stock' : 'Out of Stock',
                      isHighlight: true,
                    ),
                    _buildTableRow(
                      'Warranty',
                      Icons.security_outlined,
                      data,
                      (p) => '6 months',
                      isLast: true,
                    ),

                    // Specs Section Header
                    _buildSectionHeader('SPECS'),

                    _buildTableRow(
                      'Display',
                      Icons.phone_android_outlined,
                      data,
                      (p) {
                        final size = p.phoneModel?.displaySize ?? '';
                        final type = p.phoneModel?.displayType ?? '';
                        if (size.isEmpty && type.isEmpty) return '-';
                        return '$size $type'.trim();
                      },
                    ),
                    _buildTableRow(
                      'Processor',
                      Icons.memory_outlined,
                      data,
                      (p) => p.phoneModel?.processor ?? '-',
                    ),
                    _buildTableRow(
                      'RAM',
                      Icons.memory,
                      data,
                      (p) => p.phoneModel?.ram ?? '-',
                    ),
                    _buildTableRow(
                      'Camera',
                      Icons.camera_alt_outlined,
                      data,
                      (p) => p.phoneModel?.camera ?? '-',
                    ),
                    _buildTableRow(
                      'Battery',
                      Icons.battery_charging_full_outlined,
                      data,
                      (p) => p.phoneModel?.battery ?? '-',
                    ),
                    _buildTableRow(
                      'OS',
                      Icons.android,
                      data,
                      (p) => p.phoneModel?.os ?? '-',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    // Generate discount if original price is available
    final hasDiscount =
        product.originalPrice != null && product.originalPrice! > product.price;
    final discountPercent = hasDiscount
        ? (((product.originalPrice! - product.price) / product.originalPrice!) *
                  100)
              .round()
        : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Image Box
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SizedBox(
                height: 70,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Brand
          Text(
            product.phoneModel?.brand?.name.toUpperCase() ?? 'BRAND',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D6EFD),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            product.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Price
          Text(
            '₹${product.price.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          if (hasDiscount) ...[
            Text(
              '₹${product.originalPrice!.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$discountPercent% OFF',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.green, // Or Color(0xFF198754)
              ),
            ),
          ] else ...[
            const SizedBox(height: 16), // Padding if no original price
          ],
          const SizedBox(height: 12),
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, // Buy action would go here
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'View & Buy →',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1B2230),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String label,
    IconData icon,
    CompareResponse data,
    String Function(Product) getValue, {
    bool isLast = false,
    bool isHighlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Label
            SizedBox(
              width: 100, // Slightly wider for icon
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Values across columns
            ...data.compareProducts.map((p) {
              final val = getValue(p);
              return Expanded(
                child: Center(
                  child: isHighlight && val == 'In Stock'
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                val,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          val,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Simple parsers since product title follows format e.g. "Galaxy S22 - 128GB Black"
  String _parseStorage(String title) {
    if (title.contains('256GB')) return '256GB';
    if (title.contains('128GB')) return '128GB';
    if (title.contains('512GB')) return '512GB';
    if (title.contains('64GB')) return '64GB';
    return '-';
  }

  String _parseColor(String title) {
    final colors = [
      'Black',
      'White',
      'Graphite',
      'Violet',
      'Lime',
      'Silver',
      'Gold',
      'Blue',
      'Green',
      'Purple',
      'Grey',
    ];
    for (var c in colors) {
      if (title.toLowerCase().contains(c.toLowerCase())) return c;
    }
    return '-';
  }
}
