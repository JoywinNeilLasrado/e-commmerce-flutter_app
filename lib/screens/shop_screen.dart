import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart'; // I need to make sure this exists or create it

import '../models/shop_params.dart';

final shopProductsProvider =
    FutureProvider.family<ProductsResponse, ShopParams>((ref, params) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getProducts(
        brand: params.brand,
        conditions: params.conditions,
        minPrice: params.minPrice,
        maxPrice: params.maxPrice,
        sort: params.sort,
        search: params.search,
        page: params.page,
      );
    });

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter State
  String? _selectedBrand;
  List<int> _selectedConditions = [];
  double? _minPrice;
  double? _maxPrice;
  String _sort = 'latest';
  int _currentPage = 1;

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = ShopParams(
      brand: _selectedBrand,
      conditions: _selectedConditions.isEmpty ? null : _selectedConditions,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sort: _sort,
      search: _searchController.text.isEmpty ? null : _searchController.text,
      page: _currentPage,
    );

    final productsAsync = ref.watch(shopProductsProvider(params));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF0FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Phones',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined, color: Colors.black),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for phones...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),
        ),
      ),
      endDrawer: _buildFilterDrawer(productsAsync),
      body: productsAsync.when(
        data: (response) => _buildProductGrid(response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProductGrid(ProductsResponse response) {
    if (response.products.data.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${response.products.total} products found',
                style: const TextStyle(color: Colors.grey),
              ),
              DropdownButton<String>(
                value: _sort,
                items: const [
                  DropdownMenuItem(value: 'latest', child: Text('Newest')),
                  DropdownMenuItem(
                    value: 'price_low',
                    child: Text('Price: Low'),
                  ),
                  DropdownMenuItem(
                    value: 'price_high',
                    child: Text('Price: High'),
                  ),
                  DropdownMenuItem(value: 'popular', child: Text('Popular')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _sort = val;
                      _currentPage = 1;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: response.products.data.length,
              itemBuilder: (context, index) {
                final product = response.products.data[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.push('/products/${product.slug}');
                  },
                );
              },
            ),
          ),
        ),
        // Pagination
        if (response.products.lastPage > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text('Page $_currentPage of ${response.products.lastPage}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < response.products.lastPage
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterDrawer(AsyncValue<ProductsResponse> asyncResponse) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: asyncResponse.when(
            data: (response) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Brand',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedBrand,
                  hint: const Text('All Brands'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Brands'),
                    ),
                    ...response.brands.map(
                      (b) =>
                          DropdownMenuItem(value: b.slug, child: Text(b.name)),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedBrand = val);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Condition',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...response.conditions.map(
                  (c) => CheckboxListTile(
                    title: Text(c.name),
                    value: _selectedConditions.contains(c.id),
                    onChanged: (selected) {
                      setState(() {
                        if (selected!) {
                          _selectedConditions.add(c.id);
                        } else {
                          _selectedConditions.remove(c.id);
                        }
                      });
                    },
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedBrand = null;
                            _selectedConditions = [];
                            _minPrice = null;
                            _maxPrice = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading filters: $err'),
          ),
        ),
      ),
    );
  }
}
