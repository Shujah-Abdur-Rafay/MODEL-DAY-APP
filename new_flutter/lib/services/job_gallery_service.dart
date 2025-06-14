import 'package:flutter/foundation.dart';
import '../models/job_gallery.dart';
import 'firebase_service_template.dart';

class JobGalleryService {
  static const String _collectionName = 'job_gallery';

  static Future<List<JobGallery>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<JobGallery>((doc) => JobGallery.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching job gallery: $e');
      return [];
    }
  }

  static Future<JobGallery?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return JobGallery.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching job gallery item: $e');
      return null;
    }
  }

  static Future<JobGallery?> create(Map<String, dynamic> galleryData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, galleryData);
      if (docId != null) {
        return await getById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating job gallery item: $e');
      return null;
    }
  }

  static Future<JobGallery?> update(String id, Map<String, dynamic> galleryData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, galleryData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating job gallery item: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting job gallery item: $e');
      return false;
    }
  }

  static Future<List<JobGallery>> getByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, startDate, endDate, dateField: 'date'
      );
      return documents.map<JobGallery>((doc) => JobGallery.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching job gallery by date range: $e');
      return [];
    }
  }

  static Future<List<JobGallery>> search(String query) async {
    try {
      final documents = await FirebaseServiceTemplate.searchDocuments(_collectionName, 'title', query);
      return documents.map<JobGallery>((doc) => JobGallery.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error searching job gallery: $e');
      return [];
    }
  }
}
