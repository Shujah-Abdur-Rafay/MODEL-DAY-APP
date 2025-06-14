import 'package:flutter/foundation.dart';
import '../models/on_stay.dart';
import 'firebase_service_template.dart';

class OnStayService {
  static const String _collectionName = 'on_stay';

  static Future<List<OnStay>> list() async {
    try {
      debugPrint('🏨 OnStayService.list() - Fetching documents from $_collectionName');
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('🏨 OnStayService.list() - Found ${documents.length} documents');

      final stays = documents.map<OnStay>((doc) {
        debugPrint('🏨 OnStayService.list() - Processing document: ${doc['id']}');
        debugPrint('🏨 OnStayService.list() - Document data: $doc');
        return OnStay.fromJson(doc);
      }).toList();

      debugPrint('🏨 OnStayService.list() - Returning ${stays.length} stays');
      return stays;
    } catch (e) {
      debugPrint('🏨 Error fetching on stay records: $e');
      return [];
    }
  }

  static Future<OnStay?> create(Map<String, dynamic> onStayData) async {
    try {
      debugPrint('🏨 OnStayService.create() - Creating stay with data: $onStayData');
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, onStayData);
      debugPrint('🏨 OnStayService.create() - Created document with ID: $docId');

      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        debugPrint('🏨 OnStayService.create() - Retrieved document: $doc');
        if (doc != null) {
          final stay = OnStay.fromJson(doc);
          debugPrint('🏨 OnStayService.create() - Created stay: ${stay.locationName}');
          return stay;
        }
      }
      debugPrint('🏨 OnStayService.create() - Failed to create stay');
      return null;
    } catch (e) {
      debugPrint('🏨 Error creating on stay record: $e');
      return null;
    }
  }

  static Future<OnStay?> update(String id, Map<String, dynamic> onStayData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, onStayData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return OnStay.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating on stay record: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting on stay record: $e');
      return false;
    }
  }

  static Future<List<OnStay>> getUpcoming() async {
    try {
      final now = DateTime.now();
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, now, now.add(const Duration(days: 365)), dateField: 'startDate'
      );
      return documents.map<OnStay>((doc) => OnStay.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching upcoming on stay records: $e');
      return [];
    }
  }

  static Future<List<OnStay>> getCurrent() async {
    try {
      final now = DateTime.now();
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, now.subtract(const Duration(days: 30)), now, dateField: 'startDate'
      );
      return documents.map<OnStay>((doc) => OnStay.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching current on stay records: $e');
      return [];
    }
  }

  static Future<List<OnStay>> getPast() async {
    try {
      final now = DateTime.now();
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, now.subtract(const Duration(days: 365)), now.subtract(const Duration(days: 1)), dateField: 'endDate'
      );
      return documents.map<OnStay>((doc) => OnStay.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching past on stay records: $e');
      return [];
    }
  }
}
