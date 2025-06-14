import 'package:flutter/foundation.dart';
import '../models/model.dart';
import 'firebase_service_template.dart';

class ModelsService {
  static const String _collectionName = 'models';

  static Future<List<Model>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<Model>((doc) => Model.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching models: $e');
      return [];
    }
  }

  static Future<Model?> create(Map<String, dynamic> modelData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, modelData);
      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          return Model.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating model: $e');
      return null;
    }
  }

  static Future<Model?> update(String id, Map<String, dynamic> modelData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, modelData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return Model.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating model: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting model: $e');
      return false;
    }
  }

  static Future<Model?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Model.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching model: $e');
      return null;
    }
  }

  static Future<List<Model>> searchByName(String query) async {
    try {
      final models = await list();
      return models.where((model) => 
        model.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      debugPrint('Error searching models: $e');
      return [];
    }
  }
}
