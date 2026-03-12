import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/shop_params.dart';
import 'shop_screen.dart'; // To reuse shopProductsProvider
import '../widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {}); // Re-builds to fetch new query
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final params = ShopParams(search: query.isEmpty ? null : query);

    final productsAsync = ref.watch(shopProductsProvider(params));

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAFE),
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search phones, brands...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          onSubmitted: (_) => _performSearch(),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_outlined, color: Colors.blue),
            onPressed: () => context.go('/compare'),
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              _searchController.clear();
              _performSearch();
            },
          ),
        ],
      ),
      body: query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Type to search products',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : productsAsync.when(
              data: (data) {
                if (data.products.data.isEmpty) {
                  return const Center(child: Text('No matching products.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: data.products.data.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: data.products.data[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
    );
  }
}
