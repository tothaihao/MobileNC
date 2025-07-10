class CartItem {
  final String productId;
  final String title;
  final String image;
  final int price;
  final int quantity;
  final int? salePrice;

  CartItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
    this.salePrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
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

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;
  final int totalPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['items'] as List).map((e) => CartItem.fromJson(e)).toList();
    return Cart(
      id: json['_id'],
      userId: json['userId'],
      items: itemsList,
      totalPrice: json['totalPrice'],
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
} 