import 'package:flutter/foundation.dart';
import '../models/polaroid.dart';
import 'firebase_service_template.dart';

class PolaroidsService {
  static const String _collectionName = 'polaroids';

  static Future<List<Polaroid>> list() async {
    try {
      debugPrint('📸 PolaroidsService.list() - Fetching documents from $_collectionName');
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('📸 PolaroidsService.list() - Found ${documents.length} documents');

      final polaroids = documents.map<Polaroid>((doc) {
        debugPrint('📸 PolaroidsService.list() - Processing document: ${doc['id']}');
        debugPrint('📸 PolaroidsService.list() - Document data: $doc');
        return Polaroid.fromJson(doc);
      }).toList();

      debugPrint('📸 PolaroidsService.list() - Returning ${polaroids.length} polaroids');
      return polaroids;
    } catch (e) {
      debugPrint('📸 Error fetching polaroids: $e');
      return [];
    }
  }

  static Future<Polaroid?> create(Map<String, dynamic> polaroidData) async {
    try {
      debugPrint('📸 PolaroidsService.create() - Creating polaroid with data: $polaroidData');
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, polaroidData);
      debugPrint('📸 PolaroidsService.create() - Created document with ID: $docId');

      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        debugPrint('📸 PolaroidsService.create() - Retrieved document: $doc');
        if (doc != null) {
          final polaroid = Polaroid.fromJson(doc);
          debugPrint('📸 PolaroidsService.create() - Created polaroid: ${polaroid.clientName}');
          return polaroid;
        }
      }
      debugPrint('📸 PolaroidsService.create() - Failed to create polaroid');
      return null;
    } catch (e) {
      debugPrint('📸 Error creating polaroid: $e');
      return null;
    }
  }

  static Future<Polaroid?> update(String id, Map<String, dynamic> polaroidData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, polaroidData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return Polaroid.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating polaroid: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting polaroid: $e');
      return false;
    }
  }

  static Future<Polaroid?> getPolaroidById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Polaroid.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching polaroid: $e');
      return null;
    }
  }

  static Future<Polaroid?> updatePolaroid(String id, Map<String, dynamic> polaroidData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, polaroidData);
      if (success) {
        return await getPolaroidById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating polaroid: $e');
      return null;
    }
  }

  static Future<Polaroid?> createPolaroid(Map<String, dynamic> polaroidData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, polaroidData);
      if (docId != null) {
        return await getPolaroidById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating polaroid: $e');
      return null;
    }
  }

  static Future<List<Polaroid>> getPolaroids() async {
    return await list();
  }
}
