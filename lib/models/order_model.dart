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
      productId: json['productId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      price: (json['price'] is int) ? json['price'] : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      quantity: (json['quantity'] is int) ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
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
  final String? address;

  Order({
    required this.id,
    required this.userId,
    required this.cartItems,
    required this.totalAmount,
    required this.orderStatus,
    this.addressId,
    this.address,
    this.voucherCode,
    required this.paymentMethod,
    required this.paymentStatus,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> itemsList = [];
    if (json['cartItems'] != null) {
      var cartItemsData = json['cartItems'];
      if (cartItemsData is List) {
        itemsList = cartItemsData.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    
    return Order(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      cartItems: itemsList,
      totalAmount: (json['totalAmount'] is int) ? json['totalAmount'] : int.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0,
      orderStatus: json['orderStatus']?.toString() ?? '',
      addressId: json['addressId']?.toString(),
      address: _parseAddress(json['address']),
      voucherCode: json['voucherCode']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderDate: json['orderDate'] != null ? DateTime.tryParse(json['orderDate'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  static String? _parseAddress(dynamic addressData) {
    if (addressData == null) return null;
    if (addressData is String) return addressData;
    if (addressData is Map<String, dynamic>) {
      // If address is an object, try to construct a string from it
      String addr = '';
      if (addressData['street'] != null) addr += addressData['street'].toString();
      if (addressData['district'] != null) addr += ', ${addressData['district']}';
      if (addressData['city'] != null) addr += ', ${addressData['city']}';
      return addr.isNotEmpty ? addr : null;
    }
    return addressData.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'addressId': addressId,
      'address': address,
      'voucherCode': voucherCode,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderDate': orderDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
