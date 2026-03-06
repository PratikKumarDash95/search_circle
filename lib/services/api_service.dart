import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base API service — handles all HTTP communication with the backend.
/// Automatically attaches JWT token to requests.
class ApiService {
  // Change this to your backend URL / local IP
  // static const String _baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String _baseUrl = 'http://localhost:5000/api'; // iOS simulator
  static const String _baseUrl = 'http://10.16.5.36:5000/api'; // Physical device (Wi-Fi)

  static String get baseUrl => _baseUrl;
  static String get uploadsUrl => _baseUrl.replaceAll('/api', '');

  // ─── Token Management ──────────────────────────────────────────
  static String? _token;

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── HTTP Methods ──────────────────────────────────────────────

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request
  static Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _headers());
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request (JSON body)
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// PUT request (JSON body)
  static Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Multipart upload (for files)
  static Future<Map<String, dynamic>> uploadFile(
    String path, {
    required Map<String, File> files,
    Map<String, String>? fields,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Multipart upload for multiple files with same field name
  static Future<Map<String, dynamic>> uploadMultipleFiles(
    String path, {
    required String fieldName,
    required List<File> files,
    Map<String, String>? fields,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      for (final file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(fieldName, file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ─── Response Handlers ─────────────────────────────────────────

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      // Handle 401 — token expired
      if (response.statusCode == 401) {
        clearToken();
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Request failed',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid response from server',
        'statusCode': response.statusCode,
      };
    }
  }

  static Map<String, dynamic> _handleError(dynamic error) {
    debugPrint('API Error: $error');
    return {
      'success': false,
      'message': error is SocketException
          ? 'No internet connection'
          : 'Connection error: ${error.toString()}',
    };
  }
}
