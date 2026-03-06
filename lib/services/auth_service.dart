import 'api_service.dart';

/// Auth service — handles OTP send/verify, login state, and user data caching.
class AuthService {
  static Map<String, dynamic>? _currentUser;

  /// Get cached current user
  static Map<String, dynamic>? get currentUser => _currentUser;

  /// Send OTP to phone number
  static Future<Map<String, dynamic>> sendOtp({
    required String phone,
    String countryCode = '+91',
  }) async {
    return await ApiService.post('/auth/send-otp', body: {
      'phone': phone,
      'country_code': countryCode,
    });
  }

  /// Verify OTP and login/register
  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String countryCode = '+91',
  }) async {
    final result = await ApiService.post('/auth/verify-otp', body: {
      'phone': phone,
      'otp': otp,
      'country_code': countryCode,
    });

    if (result['success'] == true && result['token'] != null) {
      await ApiService.setToken(result['token']);
      _currentUser = result['user'];
    }

    return result;
  }

  /// Get current user from server
  static Future<Map<String, dynamic>> getMe() async {
    final result = await ApiService.get('/auth/me');
    if (result['success'] == true) {
      _currentUser = result['user'];
    }
    return result;
  }

  /// Refresh token
  static Future<Map<String, dynamic>> refreshToken() async {
    final result = await ApiService.post('/auth/refresh');
    if (result['success'] == true && result['token'] != null) {
      await ApiService.setToken(result['token']);
    }
    return result;
  }

  /// Logout
  static Future<void> logout() async {
    _currentUser = null;
    await ApiService.clearToken();
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await ApiService.isLoggedIn();
  }
}
