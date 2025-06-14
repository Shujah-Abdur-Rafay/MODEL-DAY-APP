import 'package:flutter/foundation.dart';
import '../models/test.dart';
import 'firebase_service_template.dart';

class TestsService {
  static const String _collectionName = 'tests';

  static Future<List<Test>> list() async {
    try {
      debugPrint('🧪 TestsService.list() - Fetching documents from $_collectionName');
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('🧪 TestsService.list() - Found ${documents.length} documents');

      final tests = documents.map<Test>((doc) {
        debugPrint('🧪 TestsService.list() - Processing document: ${doc['id']}');
        debugPrint('🧪 TestsService.list() - Document data: $doc');
        return Test.fromJson(doc);
      }).toList();

      debugPrint('🧪 TestsService.list() - Returning ${tests.length} tests');
      return tests;
    } catch (e) {
      debugPrint('🧪 Error fetching tests: $e');
      return [];
    }
  }

  static Future<Test?> create(Map<String, dynamic> testData) async {
    try {
      debugPrint('🧪 TestsService.create() - Creating test with data: $testData');
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, testData);
      debugPrint('🧪 TestsService.create() - Created document with ID: $docId');

      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        debugPrint('🧪 TestsService.create() - Retrieved document: $doc');
        if (doc != null) {
          final test = Test.fromJson(doc);
          debugPrint('🧪 TestsService.create() - Created test: ${test.title}');
          return test;
        }
      }
      debugPrint('🧪 TestsService.create() - Failed to create test');
      return null;
    } catch (e) {
      debugPrint('🧪 Error creating test: $e');
      return null;
    }
  }

  static Future<Test?> update(String id, Map<String, dynamic> testData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, testData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return Test.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating test: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting test: $e');
      return false;
    }
  }

  // Compatibility method
  static Future<Test?> get(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Test.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching test: $e');
      return null;
    }
  }
}
