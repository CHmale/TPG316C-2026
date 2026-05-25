import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  // Simulated upload – always returns a fake URL
  Future<String?> uploadDocument(String applicationId, File file) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate a fake URL (this will be stored in the database)
    final fakeUrl = 'https://example.com/documents/$applicationId/document.pdf';
    print('SIMULATED UPLOAD: $fakeUrl');
    return fakeUrl;
  }
}
