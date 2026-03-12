import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';
import '../services/api_service.dart';
import 'dart:async';

final cartProvider = AsyncNotifierProvider<CartNotifier, Cart>(() {
  return CartNotifier();
});

class CartNotifier extends AsyncNotifier<Cart> {
  ApiService get _apiService => ref.read(apiServiceProvider);

  @override
  FutureOr<Cart> build() async {
    return _apiService.getCart();
  }

  Future<void> fetchCart() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _apiService.getCart());
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _apiService.addToCart(productId, quantity);
      return _apiService.getCart();
    });
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _apiService.updateCartItem(cartItemId, quantity);
      return _apiService.getCart();
    });
  }

  Future<void> removeItem(int cartItemId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _apiService.removeCartItem(cartItemId);
      return _apiService.getCart();
    });
  }

  int get itemCount {
    return state.maybeWhen(
      data: (cart) => cart.items.length,
      orElse: () => 0,
    );
  }
}
