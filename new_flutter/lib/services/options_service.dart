import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/option.dart';

class OptionsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  static CollectionReference get _optionsCollection {
    return _firestore.collection('users').doc(_userId).collection('options');
  }

  /// Create a new option
  static Future<String> create(Map<String, dynamic> optionData) async {
    try {
      final docRef = await _optionsCollection.add({
        ...optionData,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create option: $e');
    }
  }

  /// Get all options for the current user
  static Future<List<Option>> list() async {
    try {
      final querySnapshot = await _optionsCollection
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        // Convert Firestore Timestamps to DateTime strings
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }
        
        return Option.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch options: $e');
    }
  }

  /// Get a specific option by ID
  static Future<Option?> getById(String optionId) async {
    try {
      final doc = await _optionsCollection.doc(optionId).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      
      // Convert Firestore Timestamps to DateTime strings
      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }
      
      return Option.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch option: $e');
    }
  }

  /// Update an existing option
  static Future<void> update(String optionId, Map<String, dynamic> optionData) async {
    try {
      await _optionsCollection.doc(optionId).update({
        ...optionData,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update option: $e');
    }
  }

  /// Delete an option
  static Future<void> delete(String optionId) async {
    try {
      await _optionsCollection.doc(optionId).delete();
    } catch (e) {
      throw Exception('Failed to delete option: $e');
    }
  }

  /// Get options by status
  static Future<List<Option>> getByStatus(String status) async {
    try {
      final querySnapshot = await _optionsCollection
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        // Convert Firestore Timestamps to DateTime strings
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }
        
        return Option.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch options by status: $e');
    }
  }

  /// Get options by date range
  static Future<List<Option>> getByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final querySnapshot = await _optionsCollection
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .orderBy('date')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        // Convert Firestore Timestamps to DateTime strings
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }
        
        return Option.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch options by date range: $e');
    }
  }

  /// Search options by client name or type
  static Future<List<Option>> search(String query) async {
    try {
      final allOptions = await list();
      
      return allOptions.where((option) {
        final clientName = option.clientName.toLowerCase();
        final type = option.type.toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return clientName.contains(searchQuery) || type.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search options: $e');
    }
  }
}
