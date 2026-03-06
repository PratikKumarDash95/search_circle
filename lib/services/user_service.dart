import 'dart:io';
import 'api_service.dart';

/// User service — handles profile, settings, and location.
class UserService {
  /// Get own profile
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/users/me');
  }

  /// Update profile (name, avatar)
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    File? avatar,
  }) async {
    if (avatar != null) {
      return await ApiService.uploadFile(
        '/users/me',
        files: {'avatar': avatar},
        fields: {if (name != null) 'name': name},
      );
    } else {
      return await ApiService.put('/users/me', body: {
        if (name != null) 'name': name,
      });
    }
  }

  /// Get public profile of another user
  static Future<Map<String, dynamic>> getPublicProfile(String userId) async {
    return await ApiService.get('/users/$userId');
  }

  /// Update location
  static Future<Map<String, dynamic>> updateLocation({
    required double lat,
    required double lng,
  }) async {
    return await ApiService.put('/users/location', body: {
      'lat': lat,
      'lng': lng,
    });
  }

  /// Get settings
  static Future<Map<String, dynamic>> getSettings() async {
    return await ApiService.get('/users/settings');
  }

  /// Update settings
  static Future<Map<String, dynamic>> updateSettings({
    bool? notificationsEnabled,
    bool? locationSharing,
    bool? privacyMode,
    bool? darkMode,
  }) async {
    final body = <String, dynamic>{};
    if (notificationsEnabled != null) body['notifications_enabled'] = notificationsEnabled;
    if (locationSharing != null) body['location_sharing'] = locationSharing;
    if (privacyMode != null) body['privacy_mode'] = privacyMode;
    if (darkMode != null) body['dark_mode'] = darkMode;

    return await ApiService.put('/users/settings', body: body);
  }
}
