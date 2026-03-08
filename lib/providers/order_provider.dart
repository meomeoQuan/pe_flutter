import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/db_helper.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  double get totalRevenue =>
      _orders.fold(0.0, (sum, order) => sum + order.totalAmount);

  // ── Load orders ─────────────────────────────────────────────────────

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final orderMaps = await _db.queryAll('orders');
      final List<Order> loaded = [];

      for (final orderMap in orderMaps) {
        final itemMaps = await _db.queryWhere(
          'order_items',
          where: 'orderId = ?',
          whereArgs: [orderMap['id']],
        );
        final items = itemMaps.map((m) => OrderItem.fromMap(m)).toList();
        loaded.add(Order.fromMap(orderMap, items));
      }

      _orders = loaded;
      // Sort newest first
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Checkout ────────────────────────────────────────────────────────

  Future<void> checkout(List<CartItem> cartItems, double total) async {
    final orderId = const Uuid().v4();
    final now = DateTime.now();

    final order = Order(
      id: orderId,
      totalAmount: total,
      createdAt: now,
    );

    await _db.insert('orders', order.toMap());

    final List<OrderItem> orderItems = [];
    for (final cartItem in cartItems) {
      final orderItem = OrderItem(
        id: const Uuid().v4(),
        orderId: orderId,
        productName: cartItem.name,
        price: cartItem.price,
        quantity: cartItem.quantity,
      );
      await _db.insert('order_items', orderItem.toMap());
      orderItems.add(orderItem);
    }

    _orders.insert(
      0,
      Order(
        id: orderId,
        totalAmount: total,
        createdAt: now,
        items: orderItems,
      ),
    );
    notifyListeners();
  }

  // ── Revenue filters ─────────────────────────────────────────────────

  double revenueForDay(DateTime date) {
    return _orders
        .where((o) =>
            o.createdAt.year == date.year &&
            o.createdAt.month == date.month &&
            o.createdAt.day == date.day)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double revenueForMonth(int year, int month) {
    return _orders
        .where((o) => o.createdAt.year == year && o.createdAt.month == month)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double revenueForYear(int year) {
    return _orders
        .where((o) => o.createdAt.year == year)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }
}
