import 'package:flutter/foundation.dart';
import '../models/shooting.dart';
import 'firebase_service_template.dart';

class ShootingsService {
  static const String _collectionName = 'shootings';

  static Future<List<Shooting>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<Shooting>((doc) => Shooting.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching shootings: $e');
      return [];
    }
  }

  static Future<Shooting?> create(Map<String, dynamic> shootingData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, shootingData);
      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          return Shooting.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating shooting: $e');
      return null;
    }
  }

  static Future<Shooting?> update(String id, Map<String, dynamic> shootingData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, shootingData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return Shooting.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating shooting: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting shooting: $e');
      return false;
    }
  }

  static Future<Shooting?> getShootingById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Shooting.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching shooting: $e');
      return null;
    }
  }

  static Future<Shooting?> updateShooting(String id, Map<String, dynamic> shootingData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, shootingData);
      if (success) {
        return await getShootingById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating shooting: $e');
      return null;
    }
  }

  static Future<Shooting?> createShooting(Map<String, dynamic> shootingData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, shootingData);
      if (docId != null) {
        return await getShootingById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating shooting: $e');
      return null;
    }
  }

  static Future<List<Shooting>> getShootings() async {
    return await list();
  }
}
