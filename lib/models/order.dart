class Order {
  final String id;
  final double totalAmount;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.totalAmount,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map, [List<OrderItem>? items]) {
    return Order(
      id: map['id'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      items: items ?? [],
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      productName: map['productName'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}
