import 'package:flutter/foundation.dart';
import '../models/industry_contact.dart';
import 'firebase_service_template.dart';

class IndustryContactsService {
  static const String _collectionName = 'industry_contacts';

  Future<List<IndustryContact>> getIndustryContacts() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<IndustryContact>((doc) => IndustryContact.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching industry contacts: $e');
      return [];
    }
  }

  Future<IndustryContact?> createIndustryContact(Map<String, dynamic> contactData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, contactData);
      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          return IndustryContact.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating industry contact: $e');
      return null;
    }
  }

  Future<IndustryContact?> updateIndustryContact(String id, Map<String, dynamic> contactData) async {
    try {
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, contactData);
      if (success) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
        if (doc != null) {
          return IndustryContact.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error updating industry contact: $e');
      return null;
    }
  }

  Future<bool> deleteIndustryContact(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting industry contact: $e');
      return false;
    }
  }

  Future<IndustryContact?> getIndustryContactById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return IndustryContact.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching industry contact: $e');
      return null;
    }
  }
}
