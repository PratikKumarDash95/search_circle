import 'api_service.dart';

/// Reward service — handles wallet and points history.
class RewardService {
  /// Get wallet balance and stats
  static Future<Map<String, dynamic>> getWallet() async {
    return await ApiService.get('/rewards');
  }

  /// Get reward transaction history
  static Future<Map<String, dynamic>> getHistory({int page = 1, int limit = 20}) async {
    return await ApiService.get('/rewards/history', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }
}
