import 'product.dart';
import 'cart.dart';
import 'user.dart';

class Order {
  final int id;
  final String orderNumber;
  final int userId;
  final int addressId;
  final String status;
  final String? paymentStatus;
  final double subtotal;
  final double total;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final Address? address;
  final Payment? payment;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.addressId,
    required this.status,
    this.paymentStatus,
    required this.subtotal,
    required this.total,
    this.createdAt,
    this.items = const [],
    this.address,
    this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      userId: json['user_id'] ?? 0,
      addressId: json['address_id'] ?? 0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'],
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      items: (json['items'] as List? ?? []).map((i) => OrderItem.fromJson(i)).toList(),
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;
  final String phoneTitle;
  final String? condition;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    required this.phoneTitle,
    this.condition,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      phoneTitle: json['phone_title'] ?? '',
      condition: json['condition'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class Payment {
  final int id;
  final int orderId;
  final String transactionId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime? paidAt;
  final Map<String, dynamic>? paymentDetails;

  Payment({
    required this.id,
    required this.orderId,
    required this.transactionId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.paidAt,
    this.paymentDetails,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      transactionId: json['transaction_id'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? 'pending',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      paymentDetails: json['payment_details'],
    );
  }
}

class CheckoutData {
  final Cart cart;
  final List<Address> addresses;

  CheckoutData({required this.cart, required this.addresses});

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      cart: Cart.fromJson(json['cart']),
      addresses: (json['addresses'] as List? ?? []).map((a) => Address.fromJson(a)).toList(),
    );
  }
}

class PayUParameters {
  final String key;
  final String txnid;
  final String amount;
  final String productinfo;
  final String firstname;
  final String email;
  final String phone;
  final String surl;
  final String furl;
  final String hash;
  final String payuUrl;

  PayUParameters({
    required this.key,
    required this.txnid,
    required this.amount,
    required this.productinfo,
    required this.firstname,
    required this.email,
    required this.phone,
    required this.surl,
    required this.furl,
    required this.hash,
    required this.payuUrl,
  });

  factory PayUParameters.fromJson(Map<String, dynamic> json) {
    return PayUParameters(
      key: json['key'] ?? '',
      txnid: json['txnid'] ?? '',
      amount: json['amount'] ?? '0',
      productinfo: json['productinfo'] ?? '',
      firstname: json['firstname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      surl: json['surl'] ?? '',
      furl: json['furl'] ?? '',
      hash: json['hash'] ?? '',
      payuUrl: json['payuUrl'] ?? '',
    );
  }
}
