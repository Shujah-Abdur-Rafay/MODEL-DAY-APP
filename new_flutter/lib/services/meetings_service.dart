import 'package:flutter/foundation.dart';
import '../models/meeting.dart';
import 'firebase_service_template.dart';

class MeetingsService {
  static const String _collectionName = 'meetings';

  static Future<List<Meeting>> list() async {
    try {
      debugPrint('🏢 MeetingsService.list() - Fetching meetings...');
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      debugPrint('🏢 MeetingsService.list() - Found ${documents.length} documents');
      final meetings = documents.map<Meeting>((doc) => Meeting.fromJson(doc)).toList();
      debugPrint('🏢 MeetingsService.list() - Parsed ${meetings.length} meetings');
      return meetings;
    } catch (e) {
      debugPrint('❌ Error fetching meetings: $e');
      return [];
    }
  }

  static Future<Meeting?> create(Map<String, dynamic> meetingData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, meetingData);
      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          return Meeting.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating meeting: $e');
      return null;
    }
  }

  static Future<Meeting?> update(String id, Map<String, dynamic> meetingData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, meetingData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return Meeting.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating meeting: $e');
      return null;
    }
  }

  static Future<bool> delete(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting meeting: $e');
      return false;
    }
  }

  static Future<Meeting?> getMeetingById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Meeting.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching meeting: $e');
      return null;
    }
  }

  static Future<Meeting?> updateMeeting(String id, Map<String, dynamic> meetingData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, meetingData);
      if (success) {
        return await getMeetingById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating meeting: $e');
      return null;
    }
  }

  static Future<Meeting?> createMeeting(Map<String, dynamic> meetingData) async {
    try {
      debugPrint('🏢 MeetingsService.createMeeting() - Creating meeting with data: $meetingData');
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, meetingData);
      debugPrint('🏢 MeetingsService.createMeeting() - Created document with ID: $docId');
      if (docId != null) {
        final meeting = await getMeetingById(docId);
        debugPrint('🏢 MeetingsService.createMeeting() - Retrieved meeting: ${meeting?.clientName}');
        return meeting;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error creating meeting: $e');
      return null;
    }
  }

  static Future<List<Meeting>> getUpcomingMeetings() async {
    try {
      final now = DateTime.now();
      final documents = await FirebaseServiceTemplate.getDocumentsByDateRange(
        _collectionName, now, now.add(const Duration(days: 365)), dateField: 'date'
      );
      return documents.map<Meeting>((doc) => Meeting.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching upcoming meetings: $e');
      return [];
    }
  }
}
