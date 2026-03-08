import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // ── Add to cart ─────────────────────────────────────────────────────

  void addToCart(Product product) {
    final existingIndex =
        _items.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: const Uuid().v4(),
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
        imageUrl: product.imageUrl,
      ));
    }
    notifyListeners();
  }

  // ── Remove from cart ────────────────────────────────────────────────

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ── Update quantity ─────────────────────────────────────────────────

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeFromCart(id);
      return;
    }

    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  // ── Clear ───────────────────────────────────────────────────────────

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
