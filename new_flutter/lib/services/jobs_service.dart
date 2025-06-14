import 'package:flutter/foundation.dart';
import '../models/job.dart';
import 'firebase_service_template.dart';

class JobsService {
  static const String _collectionName = 'jobs';

  static Future<List<Job>> list() async {
    try {
      debugPrint('🔍 JobsService.list() - Fetching jobs from collection: $_collectionName');
      debugPrint('🔍 JobsService.list() - User authenticated: ${FirebaseServiceTemplate.isAuthenticated}');
      debugPrint('🔍 JobsService.list() - Current user ID: ${FirebaseServiceTemplate.currentUserId}');

      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('🔍 JobsService.list() - Retrieved ${documents.length} documents');

      final jobs = documents.map<Job>((doc) {
        debugPrint('🔍 JobsService.list() - Processing document: ${doc['id']}');
        return Job.fromJson(doc);
      }).toList();

      debugPrint('✅ JobsService.list() - Successfully converted ${jobs.length} jobs');
      return jobs;
    } catch (e) {
      debugPrint('❌ JobsService.list() - Error fetching jobs: $e');
      return [];
    }
  }

  static Future<Job?> get(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Job.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching job: $e');
      return null;
    }
  }

  static Future<Job?> create(Map<String, dynamic> data) async {
    try {
      debugPrint('🔍 JobsService.create() - Creating job with data: $data');
      debugPrint('🔍 JobsService.create() - User authenticated: ${FirebaseServiceTemplate.isAuthenticated}');

      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, data);
      debugPrint('🔍 JobsService.create() - Created document with ID: $docId');

      if (docId != null) {
        final job = await get(docId);
        debugPrint('✅ JobsService.create() - Successfully created job: ${job?.id}');
        return job;
      }
      debugPrint('❌ JobsService.create() - Failed to create document');
      return null;
    } catch (e) {
      debugPrint('❌ JobsService.create() - Error creating job: $e');
      return null;
    }
  }

  static Future<Job?> update(String id, Map<String, dynamic> data) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, data);
      if (success) {
        return await get(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating job: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting job: $e');
      return false;
    }
  }

  static Future<List<Job>> getByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName,
        startDate,
        endDate,
        dateField: 'date'
      );
      return documents.map<Job>((doc) => Job.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching jobs by date range: $e');
      return [];
    }
  }

  static Future<List<Job>> search(String query) async {
    try {
      final documents = await FirebaseServiceTemplate.searchDocuments(
        _collectionName,
        'title',
        query
      );
      return documents.map<Job>((doc) => Job.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error searching jobs: $e');
      return [];
    }
  }

  // Additional methods for compatibility
  static Future<List<Job>> getJobs() async {
    return await list();
  }

  static Future<bool> deleteJob(String id) async {
    return await delete(id);
  }
}
