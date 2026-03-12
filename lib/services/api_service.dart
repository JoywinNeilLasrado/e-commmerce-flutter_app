import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/cart.dart';
import '../models/order.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getHomeData();
});

class ApiService {
  // Use 10.0.2.2 for Android Emulator, or 127.0.0.1 for physical devices
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    // Add an interceptor to inject the JWT token into every request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // You can handle global 401 Unauthorized errors here
          return handler.next(e);
        },
      ),
    );
  }

  // Auth: Login
  Future<Response> login(String email, String password) async {
    return await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
  }

  // Auth: Register
  Future<Response> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    return await _dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // Auth: Logout
  Future<Response> logout() async {
    return await _dio.post('/logout');
  }

  // Home Screen Data
  Future<HomeData> getHomeData() async {
    final response = await _dio.get('/');
    return HomeData.fromJson(response.data);
  }

  // Shop Screen Data (Paginated & Filtered)
  Future<ProductsResponse> getProducts({
    String? brand,
    List<int>? conditions,
    double? minPrice,
    double? maxPrice,
    String? sort,
    String? search,
    int page = 1,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page};
    if (brand != null) queryParams['brand'] = brand;
    if (conditions != null && conditions.isNotEmpty) {
      queryParams['condition'] = conditions;
    }
    if (minPrice != null) queryParams['min_price'] = minPrice;
    if (maxPrice != null) queryParams['max_price'] = maxPrice;
    if (sort != null) queryParams['sort'] = sort;
    if (search != null) queryParams['search'] = search;

    final response = await _dio.get('/products', queryParameters: queryParams);
    return ProductsResponse.fromJson(response.data);
  }

  // Profile: Get Data
  Future<User> getProfile() async {
    final response = await _dio.get('/profile');
    return User.fromJson(response.data['user']);
  }

  // Profile: Update Info
  Future<User> updateProfile(String name, String email) async {
    final response = await _dio.patch(
      '/profile',
      data: {'name': name, 'email': email},
    );
    return User.fromJson(response.data['user']);
  }

  // Profile: Update Password
  Future<void> updatePassword(
    String currentPassword,
    String password,
    String passwordConfirmation,
  ) async {
    await _dio.patch(
      '/profile/password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  // Address: Store
  Future<Address> storeAddress(Map<String, dynamic> data) async {
    final response = await _dio.post('/profile/address', data: data);
    return Address.fromJson(response.data['address']);
  }

  // Address: Delete
  Future<void> deleteAddress(int id) async {
    await _dio.delete('/profile/address/$id');
  }

  // Orders
  Future<List<dynamic>> getOrders() async {
    final response = await _dio.get('/orders');
    return response.data['orders'];
  }

  // Products: Detail
  Future<ProductDetailResponse> getProductDetail(String slug) async {
    final response = await _dio.get('/products/$slug');
    return ProductDetailResponse.fromJson(response.data);
  }

  // Products: Compare
  Future<CompareResponse> getCompareData(List<int> ids) async {
    final queryParams = ids.map((id) => 'ids[]=$id').join('&');
    final response = await _dio.get('/compare?$queryParams');
    return CompareResponse.fromJson(response.data);
  }

  // Wishlist: Get
  Future<List<Product>> getWishlist() async {
    final response = await _dio.get('/wishlist');
    return (response.data['products'] as List)
        .map((p) => Product.fromJson(p))
        .toList();
  }

  // Wishlist: Toggle
  Future<Map<String, dynamic>> toggleWishlist(int productId) async {
    final response = await _dio.post('/wishlist/toggle/$productId');
    return response.data;
  }

  // Cart: Get
  Future<Cart> getCart() async {
    final response = await _dio.get('/cart');
    return Cart.fromJson(response.data['cart']);
  }

  // Cart: Add
  Future<void> addToCart(int productId, int quantity) async {
    await _dio.post(
      '/cart',
      data: {'product_id': productId, 'quantity': quantity},
    );
  }

  // Cart: Update Item
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    await _dio.patch(
      '/cart/$cartItemId',
      data: {'quantity': quantity},
    );
  }

  // Cart: Remove Item
  Future<void> removeCartItem(int cartItemId) async {
    await _dio.delete('/cart/$cartItemId');
  }

  // Checkout: Get Data
  Future<CheckoutData> getCheckoutData() async {
    final response = await _dio.get('/checkout');
    return CheckoutData.fromJson(response.data);
  }

  // Checkout: Place Order
  Future<Order> placeOrder(int addressId, String paymentMethod) async {
    final response = await _dio.post(
      '/checkout',
      data: {'address_id': addressId, 'payment_method': paymentMethod},
    );
    return Order.fromJson(response.data['order']);
  }

  // Checkout: Initiate PayU
  Future<PayUParameters> initiatePayUPayment(int orderId) async {
    final response = await _dio.post(
      '/payment/payu/initiate',
      data: {'order_id': orderId},
    );
    return PayUParameters.fromJson(response.data['payment_parameters']);
  }
}
