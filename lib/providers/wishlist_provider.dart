import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

final wishlistProvider = NotifierProvider<WishlistNotifier, List<Product>>(() {
  return WishlistNotifier();
});

class WishlistNotifier extends Notifier<List<Product>> {
  ApiService get _apiService => ref.read(apiServiceProvider);

  @override
  List<Product> build() {
    // Listen to auth changes to fetch wishlist when logged in
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated) {
      _fetchWishlist();
    }
    return [];
  }

  Future<void> _fetchWishlist() async {
    try {
      final wishlist = await _apiService.getWishlist();
      state = wishlist;
    } catch (e) {
      // Handle error
    }
  }

  bool isWishlisted(int productId) {
    return state.any((p) => p.id == productId);
  }

  Future<void> toggle(Product product) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return;

    final isAlreadyWishlisted = isWishlisted(product.id);

    // Optimistic update
    if (isAlreadyWishlisted) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }

    try {
      await _apiService.toggleWishlist(product.id);
      // Backend handles the logic, we already updated state optimistically
    } catch (e) {
      // Revert on error
      if (isAlreadyWishlisted) {
        state = [...state, product];
      } else {
        state = state.where((p) => p.id != product.id).toList();
      }
    }
  }
}
