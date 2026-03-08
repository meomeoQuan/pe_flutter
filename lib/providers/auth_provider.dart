import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../database/db_helper.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  // ── Helpers ─────────────────────────────────────────────────────────

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // ── Register ────────────────────────────────────────────────────────

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if email already exists
      final existing = await _db.queryWhere(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (existing.isNotEmpty) {
        return 'Email already registered';
      }

      final user = User(
        id: const Uuid().v4(),
        fullName: fullName,
        email: email,
        passwordHash: _hashPassword(password),
      );

      await _db.insert('users', user.toMap());
      return null; // success
    } catch (e) {
      return 'Registration failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Login ───────────────────────────────────────────────────────────

  Future<String?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await _db.queryWhere(
        'users',
        where: 'email = ? AND passwordHash = ?',
        whereArgs: [email, _hashPassword(password)],
      );

      if (results.isEmpty) {
        return 'Invalid email or password';
      }

      _currentUser = User.fromMap(results.first);

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('remembered_email', email);
        await prefs.setString('remembered_password', password);
      }

      return null; // success
    } catch (e) {
      return 'Login failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Auto-login ──────────────────────────────────────────────────────

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email');
    final password = prefs.getString('remembered_password');

    if (email == null || password == null) return false;

    final error = await login(email: email, password: password, rememberMe: true);
    return error == null;
  }

  // ── Logout ──────────────────────────────────────────────────────────

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_email');
    await prefs.remove('remembered_password');
    notifyListeners();
  }
}
