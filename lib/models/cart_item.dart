class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl = '',
  });

  double get totalPrice => price * quantity;
}
