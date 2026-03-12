import 'product.dart';

class Cart {
  final int id;
  final int userId;
  final List<CartItem> items;
  final double total;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<CartItem> cartItems = itemsList.map((i) => CartItem.fromJson(i)).toList();
    
    // Calculate total if not provided by API
    double calculatedTotal = cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Cart(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      items: cartItems,
      total: double.tryParse(json['total']?.toString() ?? calculatedTotal.toString()) ?? calculatedTotal,
    );
  }
}

class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final double price;
  final Product? product;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      cartId: json['cart_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  double get subtotal => price * quantity;
}
