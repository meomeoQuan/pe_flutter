import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // On web, just pass the filename, databaseFactoryFfiWeb handles the IndexedDB path
    if (kIsWeb) {
      return await openDatabase(
        'pe_flutter.db',
        version: 1,
        onCreate: _onCreate,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'pe_flutter.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        totalAmount REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        productName TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Generic CRUD ──────────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // ── Mock Data Seed ────────────────────────────────────────────────────

  /// Call once on app start to populate sample data.
  /// Safe to call multiple times — skips if data already exists.
  Future<void> seedMockData() async {
    final db = await database;

    // Skip if products already exist (already seeded)
    final existing = await db.query('products');
    if (existing.isNotEmpty) return;

    // ── Helper: hash password the same way AuthProvider does ──
    String hashPw(String pw) => sha256.convert(utf8.encode(pw)).toString();

    // ── 1. Test user ─────────────────────────────────────────────
    // Login with:  test@test.com  /  123456
    await db.insert('users', {
      'id': 'user-001',
      'fullName': 'Test User',
      'email': 'test@test.com',
      'passwordHash': hashPw('123456'),
    });

    // ── 2. Sample products ───────────────────────────────────────
    final products = [
      {
        'id': 'prod-001',
        'name': 'Wireless Headphones',
        'description': 'Premium noise-cancelling Bluetooth headphones with 30-hour battery life and comfortable over-ear design.',
        'price': 79.99,
        'imageUrl': 'https://picsum.photos/seed/headphones/400/400',
      },
      {
        'id': 'prod-002',
        'name': 'Smart Watch',
        'description': 'Fitness tracker with heart rate monitor, GPS, sleep tracking, and 7-day battery life.',
        'price': 149.99,
        'imageUrl': 'https://picsum.photos/seed/smartwatch/400/400',
      },
      {
        'id': 'prod-003',
        'name': 'Portable Charger',
        'description': 'Compact 20000mAh power bank with USB-C fast charging. Charges 3 devices simultaneously.',
        'price': 34.99,
        'imageUrl': 'https://picsum.photos/seed/charger/400/400',
      },
      {
        'id': 'prod-004',
        'name': 'Mechanical Keyboard',
        'description': 'RGB backlit mechanical keyboard with hot-swappable switches and aluminum frame.',
        'price': 89.99,
        'imageUrl': 'https://picsum.photos/seed/keyboard/400/400',
      },
      {
        'id': 'prod-005',
        'name': 'Laptop Stand',
        'description': 'Adjustable ergonomic aluminum laptop stand. Fits laptops from 10" to 17".',
        'price': 29.99,
        'imageUrl': 'https://picsum.photos/seed/laptopstand/400/400',
      },
      {
        'id': 'prod-006',
        'name': 'USB-C Hub',
        'description': '7-in-1 hub with HDMI 4K, SD card reader, 3x USB 3.0, USB-C PD charging.',
        'price': 45.99,
        'imageUrl': 'https://picsum.photos/seed/usbhub/400/400',
      },
    ];

    for (final p in products) {
      await db.insert('products', p);
    }

    // ── 3. Sample orders (for revenue stats) ─────────────────────
    final now = DateTime.now();

    // Order 1: placed today
    await db.insert('orders', {
      'id': 'order-001',
      'totalAmount': 229.98,
      'createdAt': now.toIso8601String(),
    });
    await db.insert('order_items', {
      'id': 'oi-001',
      'orderId': 'order-001',
      'productName': 'Wireless Headphones',
      'price': 79.99,
      'quantity': 1,
    });
    await db.insert('order_items', {
      'id': 'oi-002',
      'orderId': 'order-001',
      'productName': 'Smart Watch',
      'price': 149.99,
      'quantity': 1,
    });

    // Order 2: placed 3 days ago
    await db.insert('orders', {
      'id': 'order-002',
      'totalAmount': 69.98,
      'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
    });
    await db.insert('order_items', {
      'id': 'oi-003',
      'orderId': 'order-002',
      'productName': 'Portable Charger',
      'price': 34.99,
      'quantity': 2,
    });
  }
}
