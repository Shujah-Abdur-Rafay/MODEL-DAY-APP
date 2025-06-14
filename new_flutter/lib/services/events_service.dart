import 'package:flutter/foundation.dart';
import '../models/event.dart';
import 'firebase_service_template.dart';

class EventsService {
  static const String _collectionName = 'events';

  Future<List<Event>> getEvents() async {
    try {
      debugPrint('📅 EventsService.getEvents() - Fetching events...');
      final documents =
          await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('📅 EventsService.getEvents() - Found ${documents.length} documents');
      final events = documents.map<Event>((doc) => Event.fromJson(doc)).toList();
      debugPrint('📅 EventsService.getEvents() - Parsed ${events.length} events');
      return events;
    } catch (e) {
      debugPrint('❌ Error fetching events: $e');
      return [];
    }
  }

  Future<Event?> createEvent(Map<String, dynamic> eventData) async {
    try {
      debugPrint('📅 EventsService.createEvent() - Creating event with data: $eventData');
      final docId = await FirebaseServiceTemplate.createDocument(
          _collectionName, eventData);
      debugPrint('📅 EventsService.createEvent() - Created document with ID: $docId');
      if (docId != null) {
        final doc =
            await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          final event = Event.fromJson(doc);
          debugPrint('📅 EventsService.createEvent() - Retrieved event: ${event.clientName}');
          return event;
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error creating event: $e');
      return null;
    }
  }

  Future<Event?> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(
          _collectionName, id, eventData);
      if (success) {
        final doc =
            await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return Event.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating event: $e');
      return null;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final doc =
          await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Event.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching event: $e');
      return null;
    }
  }
}
