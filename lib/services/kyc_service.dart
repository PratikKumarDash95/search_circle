import 'dart:io';
import 'api_service.dart';

/// KYC (Know Your Customer) service — handles ID document and selfie uploads.
class KycService {
  /// Upload front and back ID images
  static Future<Map<String, dynamic>> uploadId({
    required File frontImage,
    required File backImage,
    String docType = 'national_id',
  }) async {
    return await ApiService.uploadFile(
      '/kyc/upload-id',
      files: {
        'front': frontImage,
        'back': backImage,
      },
      fields: {
        'doc_type': docType,
      },
    );
  }

  /// Upload selfie for face verification
  static Future<Map<String, dynamic>> uploadSelfie({
    required File selfieImage,
  }) async {
    return await ApiService.uploadFile(
      '/kyc/selfie',
      files: {
        'selfie': selfieImage,
      },
    );
  }

  /// Get current KYC status
  static Future<Map<String, dynamic>> getStatus() async {
    return await ApiService.get('/kyc/status');
  }
}
