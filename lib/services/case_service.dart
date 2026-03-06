import 'dart:io';
import 'api_service.dart';

/// Case service — handles missing person cases CRUD, sighting reports.
class CaseService {
  /// Get list of cases with optional filters
  static Future<Map<String, dynamic>> getCases({
    String? filter, // near_me, urgent, recent, resolved
    double? lat,
    double? lng,
    double? radius,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (filter != null) params['filter'] = filter;
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();
    if (radius != null) params['radius'] = radius.toString();
    if (search != null) params['search'] = search;

    return await ApiService.get('/cases', queryParams: params);
  }

  /// Get single case detail
  static Future<Map<String, dynamic>> getCaseDetail(String caseId) async {
    return await ApiService.get('/cases/$caseId');
  }

  /// Create a new missing person case
  static Future<Map<String, dynamic>> createCase({
    required String name,
    required String description,
    File? photo,
    String? lastSeenLocation,
    double? lat,
    double? lng,
    int? age,
    String? gender,
    String? height,
    String? weight,
    String? distinguishingFeatures,
    String? contactInfo,
  }) async {
    final fields = <String, String>{
      'name': name,
      'description': description,
      if (lastSeenLocation != null) 'last_seen_location': lastSeenLocation,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (age != null) 'age': age.toString(),
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (distinguishingFeatures != null) 'distinguishing_features': distinguishingFeatures,
      if (contactInfo != null) 'contact_info': contactInfo,
    };

    if (photo != null) {
      return await ApiService.uploadFile('/cases', files: {'photo': photo}, fields: fields);
    } else {
      return await ApiService.post('/cases', body: fields.cast<String, dynamic>());
    }
  }

  /// Report a sighting for a case
  static Future<Map<String, dynamic>> reportSighting({
    required String caseId,
    String? description,
    String? locationText,
    double? lat,
    double? lng,
    File? photo,
  }) async {
    final fields = <String, String>{
      if (description != null) 'description': description,
      if (locationText != null) 'location_text': locationText,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
    };

    if (photo != null) {
      return await ApiService.uploadFile('/cases/$caseId/sighting', files: {'photo': photo}, fields: fields);
    } else {
      return await ApiService.post('/cases/$caseId/sighting', body: fields.cast<String, dynamic>());
    }
  }

  /// Get user's own reports
  static Future<Map<String, dynamic>> getMyReports() async {
    return await ApiService.get('/cases/my-reports');
  }
}
