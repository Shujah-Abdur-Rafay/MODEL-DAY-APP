import 'package:flutter/foundation.dart';
import '../models/casting.dart';
import 'firebase_service_template.dart';

class CastingsService {
  static const String _collectionName = 'castings';

  static Future<List<Casting>> list() async {
    try {
      debugPrint('🔍 CastingsService.list() - Fetching castings from collection: $_collectionName');
      debugPrint('🔍 CastingsService.list() - User authenticated: ${FirebaseServiceTemplate.isAuthenticated}');
      debugPrint('🔍 CastingsService.list() - Current user ID: ${FirebaseServiceTemplate.currentUserId}');

      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('🔍 CastingsService.list() - Retrieved ${documents.length} documents');

      final castings = documents.map<Casting>((doc) {
        debugPrint('🔍 CastingsService.list() - Processing document: ${doc['id']}');
        return Casting.fromJson(doc);
      }).toList();

      debugPrint('🔍 CastingsService.list() - Returning ${castings.length} castings');
      return castings;
    } catch (e) {
      debugPrint('❌ Error fetching castings: $e');
      return [];
    }
  }

  static Future<Casting?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Casting.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching casting: $e');
      return null;
    }
  }

  static Future<Casting?> create(Map<String, dynamic> castingData) async {
    try {
      debugPrint('🔍 CastingsService.create() - Creating casting with data: $castingData');
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, castingData);
      debugPrint('🔍 CastingsService.create() - Created document with ID: $docId');
      if (docId != null) {
        final casting = await getById(docId);
        debugPrint('🔍 CastingsService.create() - Retrieved created casting: ${casting?.id}');
        return casting;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error creating casting: $e');
      return null;
    }
  }

  static Future<Casting?> update(String id, Map<String, dynamic> castingData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, castingData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating casting: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting casting: $e');
      return false;
    }
  }

  // Compatibility method
  static Future<Casting?> get(String id) async {
    return await getById(id);
  }
}
