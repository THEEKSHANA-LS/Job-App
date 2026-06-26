// lib/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../constants/app_constants.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String?    _errorMessage;

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool get isAuthenticated    => _status == AuthStatus.authenticated;
  bool get isLoading          => _status == AuthStatus.loading;

  // ─── Init: restore session then refresh full profile ─────────────────
  Future<void> init() async {
    final prefs   = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);

    if (userJson == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final cached = UserModel.fromJson(map, map['token'] ?? '');

      // Show cached user immediately so the app opens fast
      _user   = cached;
      _status = AuthStatus.authenticated;
      notifyListeners();

      // Then fetch the full up-to-date profile in the background
      await _refreshFullProfile(cached.token);
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // ─── Register ────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading();
    final result = await AuthService.register(
      name: name, email: email, password: password, role: role,
    );
    if (result['success'] == true) {
      final user = result['user'] as UserModel;
      await _refreshFullProfile(user.token);
      return true;
    }
    _setError(result['message'] ?? 'Registration failed');
    return false;
  }

  // ─── Login ───────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    final result = await AuthService.login(email: email, password: password);
    if (result['success'] == true) {
      final user = result['user'] as UserModel;
      // Persist the basic user first so we're "authenticated"
      await _persistUser(user);
      // Then immediately fetch the full profile (phone, skills, cvUrl)
      await _refreshFullProfile(user.token);
      return true;
    }
    _setError(result['message'] ?? 'Login failed');
    return false;
  }

  // ─── Fetch full profile from /api/users/profile and persist ──────────
  Future<void> _refreshFullProfile(String token) async {
    try {
      final result = await UserService.getProfile(token);
      if (result['success'] == true) {
        final fullUser = result['user'] as UserModel;
        await _persistUser(fullUser);
        debugPrint('[AuthProvider] Full profile loaded → name=${fullUser.name} phone=${fullUser.phone} skills=${fullUser.skills}');
      } else {
        debugPrint('[AuthProvider] Could not refresh profile: ${result['message']}');
        // Don't log out — just keep whatever we have cached
        if (_status != AuthStatus.authenticated) {
          _status = AuthStatus.authenticated;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[AuthProvider] _refreshFullProfile error: $e');
      if (_status != AuthStatus.authenticated) {
        _status = AuthStatus.authenticated;
        notifyListeners();
      }
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Called by ProfileProvider after profile/skills/CV update ────────
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
    // Also persist so the next init() gets the latest data
    _persistUser(user);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────
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
    if (_status == AuthStatus.error) _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}