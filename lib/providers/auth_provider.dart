import 'package:flutter/material.dart';
import 'package:HarapanNews/model/user.dart';
import 'package:HarapanNews/services/auth_service.dart';
import 'package:HarapanNews/services/secure_storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _isAuthenticating = true;

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticating => _isAuthenticating;

  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    _isAuthenticating = true;
    notifyListeners();

    final storedToken = await _storageService.getToken();
    if (storedToken != null) {
      _token = storedToken;
      final storedUser = await _storageService.getUser();
      if (storedUser != null) {
        _user = storedUser;
        _isLoggedIn = true;
      }
    }

    _isAuthenticating = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      _user = response['user'];
      _token = response['token'];
      _isLoggedIn = true;

      await _storageService.saveToken(_token!);
      await _storageService.saveUser(_user!);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String title,
    required String avatar
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        title: title,
        avatar: avatar,
      );
      _user = response['user'];
      _token = response['token'];
      _isLoggedIn = true;

      await _storageService.saveToken(_token!);
      await _storageService.saveUser(_user!);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _isLoggedIn = false;

    await _storageService.deleteAll();
    notifyListeners();
  }
}
