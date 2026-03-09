import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/db_helper.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  List<Product> _products = [];
  String _searchQuery = '';
  bool _sortAscending = true;
  bool _isLoading = false;
  final Set<String> _savedProductIds = {};

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get sortAscending => _sortAscending;

  List<Product> get _filteredProducts {
    List<Product> result = _products;
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    result.sort((a, b) => _sortAscending
        ? a.price.compareTo(b.price)
        : b.price.compareTo(a.price));
    return result;
  }

  // ── Load ────────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final maps = await _db.queryAll('products');
      _products = maps.map((m) => Product.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Find by ID ──────────────────────────────────────────────────────

  Product? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Add ─────────────────────────────────────────────────────────────

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    String imageUrl = '',
  }) async {
    final product = Product(
      id: const Uuid().v4(),
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
    );

    await _db.insert('products', product.toMap());
    _products.add(product);
    notifyListeners();
  }

  // ── Update ──────────────────────────────────────────────────────────

  Future<void> updateProduct(Product product) async {
    await _db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );

    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
      notifyListeners();
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────

  Future<void> deleteProduct(String id) async {
    await _db.delete('products', where: 'id = ?', whereArgs: [id]);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ── Search ──────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Sort ────────────────────────────────────────────────────────────

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  void setSortAscending(bool ascending) {
    _sortAscending = ascending;
    notifyListeners();
  }

  // ── Wishlist / Saved ────────────────────────────────────────────────
  
  Set<String> get savedProductIds => _savedProductIds;

  List<Product> get savedProducts {
    return _products.where((p) => _savedProductIds.contains(p.id)).toList();
  }

  bool isSaved(String productId) => _savedProductIds.contains(productId);

  void toggleSaved(String productId) {
    if (_savedProductIds.contains(productId)) {
      _savedProductIds.remove(productId);
    } else {
      _savedProductIds.add(productId);
    }
    notifyListeners();
  }
}
