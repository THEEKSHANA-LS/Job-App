// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
  });
}

class ApiService {
  static Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Uri _uri(String endpoint) =>
      Uri.parse('${AppConstants.baseUrl}$endpoint');

  // ─── GET ──────────────────────────────────────────────────────────────────
  static Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final res = await http.get(
        _uri(endpoint),
        headers: _headers(token: token),
      );
      return _parse(res);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  // ─── POST ─────────────────────────────────────────────────────────────────
  static Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final res = await http.post(
        _uri(endpoint),
        headers: _headers(token: token),
        body: jsonEncode(body ?? {}),
      );
      return _parse(res);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────
  static Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final res = await http.put(
        _uri(endpoint),
        headers: _headers(token: token),
        body: jsonEncode(body ?? {}),
      );
      return _parse(res);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  static Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final res = await http.delete(
        _uri(endpoint),
        headers: _headers(token: token),
      );
      return _parse(res);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: $e',
        statusCode: 0,
      );
    }
  }

  // ─── Parser ───────────────────────────────────────────────────────────────
  static ApiResponse<Map<String, dynamic>> _parse(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return ApiResponse(
        success:    body['success'] == true,
        data:       body,
        message:    body['message'] ?? '',
        statusCode: res.statusCode,
      );
    } catch (_) {
      return ApiResponse(
        success:    false,
        message:    'Failed to parse response',
        statusCode: res.statusCode,
      );
    }
  }
}