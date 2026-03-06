import 'api_service.dart';

/// Alert service — handles notification alerts feed.
class AlertService {
  /// Get alerts for current user
  static Future<Map<String, dynamic>> getAlerts({int page = 1, int limit = 30}) async {
    return await ApiService.get('/alerts', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  /// Mark alerts as read
  static Future<Map<String, dynamic>> markRead({List<String>? alertIds}) async {
    return await ApiService.post('/alerts/mark-read', body: {
      if (alertIds != null) 'alert_ids': alertIds,
    });
  }
}
