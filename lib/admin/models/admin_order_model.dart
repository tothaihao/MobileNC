import 'admin_address_model.dart';

class Order {
  final String id;
  final String userId;
  final List<CartItem> cartItems;
  final String addressId; // sửa thành String
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final int totalAmount;
  final String? voucherCode;
  final DateTime orderDate;
  final Address? address; // luôn null, chỉ lấy qua API riêng

  Order({
    required this.id,
    required this.userId,
    required this.cartItems,
    required this.addressId,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    this.voucherCode,
    required this.orderDate,
    this.address,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      addressId: json['addressId'] ?? '', // luôn là String
      orderStatus: json['orderStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      totalAmount: json['totalAmount'] ?? 0,
      voucherCode: json['voucherCode'],
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),
      cartItems: (json['cartItems'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      address: null, // luôn null, chỉ lấy qua API riêng
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'addressId': addressId,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'voucherCode': voucherCode,
      'orderDate': orderDate.toIso8601String(),
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
    };
  }
}

class CartItem {
  final String productId;
  final String title;
  final String image;
  final int price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }
}
