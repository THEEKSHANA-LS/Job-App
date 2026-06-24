// lib/providers/profile_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';

class ProfileProvider extends ChangeNotifier {
  bool    _isLoading    = false;
  String? _errorMessage;
  String? _successMessage;

  bool    get isLoading      => _isLoading;
  String? get errorMessage   => _errorMessage;
  String? get successMessage => _successMessage;

  void _start()              { _isLoading = true;  _errorMessage = null; _successMessage = null; notifyListeners(); }
  void _fail(String msg)     { _isLoading = false; _errorMessage = msg;  notifyListeners(); }
  void _done(String msg)     { _isLoading = false; _successMessage = msg; notifyListeners(); }

  // ─── Update name / phone ─────────────────────────────────────────────
  Future<bool> updateProfile({
    required AuthProvider authProvider,
    required String name,
    required String phone,
  }) async {
    _start();
    final token  = authProvider.user?.token ?? '';
    final result = await UserService.updateProfile(
      token: token, name: name, phone: phone,
    );
    if (result['success'] == true) {
      await _persist(authProvider, result['user'] as UserModel);
      _done('Profile updated successfully');
      return true;
    }
    _fail(result['message'] ?? 'Update failed');
    return false;
  }

  // ─── Update skills ────────────────────────────────────────────────────
  Future<bool> updateSkills({
    required AuthProvider authProvider,
    required List<String> skills,
  }) async {
    _start();
    final token  = authProvider.user?.token ?? '';
    final result = await UserService.updateSkills(token: token, skills: skills);
    if (result['success'] == true) {
      await _persist(authProvider, result['user'] as UserModel);
      _done('Skills updated successfully');
      return true;
    }
    _fail(result['message'] ?? 'Update failed');
    return false;
  }

  // ─── Upload CV ────────────────────────────────────────────────────────
  Future<bool> uploadCV({
    required AuthProvider authProvider,
    required String filePath,
  }) async {
    _start();
    final token  = authProvider.user?.token ?? '';
    final result = await UserService.uploadCV(token: token, filePath: filePath);
    if (result['success'] == true) {
      // Rebuild user object with the new cvUrl
      final current = authProvider.user!;
      final updated = UserModel(
        id:           current.id,
        name:         current.name,
        email:        current.email,
        role:         current.role,
        phone:        current.phone,
        profileImage: current.profileImage,
        cvUrl:        result['cvUrl'] as String?,
        skills:       current.skills,
        isVerified:   current.isVerified,
        token:        current.token,
      );
      await _persist(authProvider, updated);
      _done('CV uploaded successfully');
      return true;
    }
    _fail(result['message'] ?? 'Upload failed');
    return false;
  }

  void clearMessages() {
    _errorMessage   = null;
    _successMessage = null;
    notifyListeners();
  }

  // ─── Persist updated user to SharedPreferences + AuthProvider ─────────
  Future<void> _persist(AuthProvider authProvider, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    authProvider.updateUser(user);
  }
}