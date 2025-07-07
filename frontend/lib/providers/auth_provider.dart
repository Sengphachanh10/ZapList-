// providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final hasToken = await StorageService.hasToken();
      if (hasToken) {
        final userData = await StorageService.getUser();
        if (userData != null) {
          _user = User.fromJson(json.decode(userData));
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      _error = 'Failed to check auth status';
    }

    _setLoading(false);
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        await StorageService.saveToken(response.data!.token);
        await StorageService.saveUser(
            json.encode(response.data!.user.toJson()));

        _user = response.data!.user;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _error = response.error ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.register(
        username: username,
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        await StorageService.saveToken(response.data!.token);
        await StorageService.saveUser(
            json.encode(response.data!.user.toJson()));

        _user = response.data!.user;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _error = response.error ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearStorage();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
