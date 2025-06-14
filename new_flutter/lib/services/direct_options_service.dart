import 'package:flutter/foundation.dart';
import '../models/direct_options.dart';
import 'firebase_service_template.dart';

class DirectOptionsService {
  static const String _collectionName = 'direct_options';

  static Future<List<DirectOptions>> list() async {
    try {
      debugPrint('🔍 DirectOptionsService.list() - Fetching from collection: $_collectionName');
      debugPrint('🔍 DirectOptionsService.list() - User authenticated: ${FirebaseServiceTemplate.isAuthenticated}');
      debugPrint('🔍 DirectOptionsService.list() - Current user ID: ${FirebaseServiceTemplate.currentUserId}');

      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('🔍 DirectOptionsService.list() - Retrieved ${documents.length} documents');

      final options = documents.map<DirectOptions>((doc) {
        debugPrint('🔍 DirectOptionsService.list() - Processing document: ${doc['id']}');
        return DirectOptions.fromJson(doc);
      }).toList();

      debugPrint('✅ DirectOptionsService.list() - Successfully converted ${options.length} direct options');
      return options;
    } catch (e) {
      debugPrint('❌ DirectOptionsService.list() - Error fetching direct options: $e');
      return [];
    }
  }

  static Future<DirectOptions?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return DirectOptions.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching direct option: $e');
      return null;
    }
  }

  static Future<DirectOptions?> create(Map<String, dynamic> optionData) async {
    try {
      debugPrint('🔍 DirectOptionsService.create() - Creating direct option with data: $optionData');
      debugPrint('🔍 DirectOptionsService.create() - User authenticated: ${FirebaseServiceTemplate.isAuthenticated}');

      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, optionData);
      debugPrint('🔍 DirectOptionsService.create() - Created document with ID: $docId');

      if (docId != null) {
        final option = await getById(docId);
        debugPrint('✅ DirectOptionsService.create() - Successfully created direct option: ${option?.id}');
        return option;
      }
      debugPrint('❌ DirectOptionsService.create() - Failed to create document');
      return null;
    } catch (e) {
      debugPrint('❌ DirectOptionsService.create() - Error creating direct option: $e');
      return null;
    }
  }

  static Future<DirectOptions?> update(String id, Map<String, dynamic> optionData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, optionData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating direct option: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting direct option: $e');
      return false;
    }
  }

  static Future<List<DirectOptions>> getByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, startDate, endDate, dateField: 'date'
      );
      return documents.map<DirectOptions>((doc) => DirectOptions.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching direct options by date range: $e');
      return [];
    }
  }

  static Future<List<DirectOptions>> search(String query) async {
    try {
      final documents = await FirebaseServiceTemplate.searchDocuments(_collectionName, 'title', query);
      return documents.map<DirectOptions>((doc) => DirectOptions.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error searching direct options: $e');
      return [];
    }
  }
}
