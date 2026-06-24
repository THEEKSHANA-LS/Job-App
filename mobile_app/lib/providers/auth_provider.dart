// lib/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String?   _errorMessage;

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool get isAuthenticated    => _status == AuthStatus.authenticated;
  bool get isLoading          => _status == AuthStatus.loading;

  // ─── Init: restore session from local storage ──────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);

    if (userJson != null) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        _user     = UserModel.fromJson(map, map['token'] ?? '');
        _status   = AuthStatus.authenticated;
      } catch (_) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ─── Register ──────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading();

    final result = await AuthService.register(
      name:     name,
      email:    email,
      password: password,
      role:     role,
    );

    if (result['success'] == true) {
      await _persistUser(result['user'] as UserModel);
      return true;
    } else {
      _setError(result['message'] ?? 'Registration failed');
      return false;
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await AuthService.login(
      email:    email,
      password: password,
    );

    if (result['success'] == true) {
      await _persistUser(result['user'] as UserModel);
      return true;
    } else {
      _setError(result['message'] ?? 'Login failed');
      return false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────
  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, user.token);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    _user         = user;
    _status       = AuthStatus.authenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status       = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Called by ProfileProvider after a successful profile/skills/CV update
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}