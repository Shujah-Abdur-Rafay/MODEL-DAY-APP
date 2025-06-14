import 'package:flutter/foundation.dart';
import '../models/agency.dart';
import 'firebase_service_template.dart';

class AgenciesService {
  static const String _collectionName = 'agencies';

  static Future<List<Agency>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<Agency>((doc) => Agency.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching agencies: $e');
      return [];
    }
  }

  static Future<Agency?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Agency.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching agency: $e');
      return null;
    }
  }

  static Future<Agency?> create(Map<String, dynamic> agencyData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, agencyData);
      if (docId != null) {
        return await getById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating agency: $e');
      return null;
    }
  }

  static Future<Agency?> update(String id, Map<String, dynamic> agencyData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, agencyData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating agency: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting agency: $e');
      return false;
    }
  }

  static Future<List<Agency>> search(String query) async {
    try {
      final documents = await FirebaseServiceTemplate.searchDocuments(_collectionName, 'name', query);
      return documents.map<Agency>((doc) => Agency.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error searching agencies: $e');
      return [];
    }
  }
}
