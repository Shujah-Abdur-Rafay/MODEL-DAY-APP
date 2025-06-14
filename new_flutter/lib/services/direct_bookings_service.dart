import 'package:flutter/foundation.dart';
import '../models/direct_booking.dart';
import 'firebase_service_template.dart';

class DirectBookingsService {
  static const String _collectionName = 'direct_bookings';

  static Future<List<DirectBooking>> list() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      final List<DirectBooking> bookings = [];

      for (final doc in documents) {
        try {
          final booking = DirectBooking.fromJson(doc);
          bookings.add(booking);
        } catch (e) {
          debugPrint('Error parsing individual direct booking document: $e');
          debugPrint('Document data: $doc');
          debugPrint('Document type: ${doc.runtimeType}');
          // Continue processing other documents
        }
      }

      return bookings;
    } catch (e) {
      debugPrint('Error fetching direct bookings: $e');
      return [];
    }
  }

  static Future<DirectBooking?> getById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        try {
          return DirectBooking.fromJson(doc);
        } catch (e) {
          debugPrint('Error parsing direct booking document with ID $id: $e');
          debugPrint('Document data: $doc');
          debugPrint('Document type: ${doc.runtimeType}');
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching direct booking: $e');
      return null;
    }
  }

  static Future<DirectBooking?> create(Map<String, dynamic> bookingData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, bookingData);
      if (docId != null) {
        return await getById(docId);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating direct booking: $e');
      return null;
    }
  }

  static Future<DirectBooking?> update(String id, Map<String, dynamic> bookingData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, bookingData);
      if (success) {
        return await getById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating direct booking: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting direct booking: $e');
      return false;
    }
  }

  static Future<List<DirectBooking>> getByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, startDate, endDate, dateField: 'date'
      );
      return documents.map<DirectBooking>((doc) => DirectBooking.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching direct bookings by date range: $e');
      return [];
    }
  }

  static Future<List<DirectBooking>> search(String query) async {
    try {
      final documents = await FirebaseServiceTemplate.searchDocuments(_collectionName, 'title', query);
      return documents.map<DirectBooking>((doc) => DirectBooking.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error searching direct bookings: $e');
      return [];
    }
  }
}
