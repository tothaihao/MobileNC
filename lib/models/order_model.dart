class OrderItem {
  final String productId;
  final String title;
  final String image;
  final int price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      title: json['title'],
      image: json['image'],
      price: json['price'],
      quantity: json['quantity'],
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

class Order {
  final String id;
  final String userId;
  final List<OrderItem> cartItems;
  final int totalAmount;
  final String orderStatus;
  final String? addressId;
  final String? voucherCode;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? orderDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.cartItems,
    required this.totalAmount,
    required this.orderStatus,
    this.addressId,
    this.voucherCode,
    this.paymentMethod,
    this.paymentStatus,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['cartItems'] as List).map((e) => OrderItem.fromJson(e)).toList();
    return Order(
      id: json['_id'],
      userId: json['userId'],
      cartItems: itemsList,
      totalAmount: json['totalAmount'],
      orderStatus: json['orderStatus'],
      addressId: json['addressId'],
      voucherCode: json['voucherCode'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'addressId': addressId,
      'voucherCode': voucherCode,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderDate': orderDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
