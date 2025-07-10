class OrderItem {
  final String productId;
  final String title;
  final String image;
  final int price;
  final int quantity;
  final int? salePrice;

  OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
    this.salePrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      title: json['title'],
      image: json['image'],
      price: json['price'],
      quantity: json['quantity'],
      salePrice: json['salePrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
      'salePrice': salePrice,
    };
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final int totalPrice;
  final String status;
  final String? address;
  final String? phone;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    this.address,
    this.phone,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList();
    return Order(
      id: json['_id'],
      userId: json['userId'],
      items: itemsList,
      totalPrice: json['totalPrice'],
      status: json['status'],
      address: json['address'],
      phone: json['phone'],
      note: json['note'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'address': address,
      'phone': phone,
      'note': note,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
} 