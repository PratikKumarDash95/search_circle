import 'dart:io';
import 'api_service.dart';

/// Evidence service — handles video/photo evidence upload and listing.
class EvidenceService {
  /// Upload evidence file (video or photo)
  static Future<Map<String, dynamic>> uploadEvidence({
    required File file,
    String? caseId,
    double? lat,
    double? lng,
    String? gpsText,
    String? description,
    int? durationSeconds,
  }) async {
    final fields = <String, String>{
      if (caseId != null) 'case_id': caseId,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (gpsText != null) 'gps_text': gpsText,
      if (description != null) 'description': description,
      if (durationSeconds != null) 'duration_seconds': durationSeconds.toString(),
    };

    return await ApiService.uploadFile(
      '/evidence/upload',
      files: {'file': file},
      fields: fields,
    );
  }

  /// Get user's upload history
  static Future<Map<String, dynamic>> getMyUploads({
    int page = 1,
    int limit = 20,
  }) async {
    return await ApiService.get('/evidence/mine', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  /// Delete an evidence file
  static Future<Map<String, dynamic>> deleteEvidence(String evidenceId) async {
    return await ApiService.delete('/evidence/$evidenceId');
  }
}
