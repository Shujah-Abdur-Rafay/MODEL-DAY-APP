import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Base template for Firebase services
/// This provides common Firebase operations that can be extended by specific services
class FirebaseServiceTemplate {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  /// Get a collection reference
  static CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }

  /// Get documents from a collection
  static Future<List<Map<String, dynamic>>> getDocuments(
      String collectionName) async {
    try {
      final snapshot = await getCollection(collectionName).get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      debugPrint('Error getting documents from $collectionName: $e');
      return [];
    }
  }

  /// Get a single document by ID
  static Future<Map<String, dynamic>?> getDocument(
      String collectionName, String id) async {
    try {
      final doc = await getCollection(collectionName).doc(id).get();
      if (doc.exists) {
        final docData = doc.data() as Map<String, dynamic>;
        return {
          ...docData,
          'id': doc.id, // Ensure document ID overrides any existing id field
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting document $id from $collectionName: $e');
      return null;
    }
  }

  /// Create a new document
  static Future<String?> createDocument(
      String collectionName, Map<String, dynamic> data) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final docData = {
        ...data,
        'userId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await getCollection(collectionName).add(docData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating document in $collectionName: $e');
      return null;
    }
  }

  /// Update a document
  static Future<bool> updateDocument(
      String collectionName, String id, Map<String, dynamic> data) async {
    try {
      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await getCollection(collectionName).doc(id).update(updateData);
      return true;
    } catch (e) {
      debugPrint('Error updating document $id in $collectionName: $e');
      return false;
    }
  }

  /// Delete a document
  static Future<bool> deleteDocument(String collectionName, String id) async {
    try {
      if (!isAuthenticated) {
        debugPrint('Error: User not authenticated for delete operation');
        return false;
      }

      if (id.isEmpty) {
        debugPrint('Error: Document ID is empty for delete operation');
        return false;
      }

      // Check if document exists before deleting
      final doc = await getCollection(collectionName).doc(id).get();
      if (!doc.exists) {
        debugPrint('Error: Document $id does not exist in $collectionName');
        return false;
      }

      // Verify the document belongs to the current user
      final data = doc.data() as Map<String, dynamic>?;
      if (data?['userId'] != currentUserId) {
        debugPrint(
            'Error: User does not have permission to delete document $id');
        return false;
      }

      await getCollection(collectionName).doc(id).delete();
      debugPrint('Successfully deleted document $id from $collectionName');
      return true;
    } catch (e) {
      debugPrint('Error deleting document $id from $collectionName: $e');
      return false;
    }
  }

  /// Get documents by date range
  static Future<List<Map<String, dynamic>>> getDocumentsByDateRange(
      String collectionName, DateTime startDate, DateTime endDate,
      {String dateField = 'createdAt'}) async {
    try {
      final snapshot = await getCollection(collectionName)
          .where(dateField,
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where(dateField, isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      debugPrint(
          'Error getting documents by date range from $collectionName: $e');
      return [];
    }
  }

  /// Search documents by text
  static Future<List<Map<String, dynamic>>> searchDocuments(
      String collectionName, String searchField, String query) async {
    try {
      // Note: Firestore doesn't have full-text search built-in
      // This is a simple prefix search
      final snapshot = await getCollection(collectionName)
          .where(searchField, isGreaterThanOrEqualTo: query)
          .where(searchField, isLessThan: '${query}z')
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      debugPrint('Error searching documents in $collectionName: $e');
      return [];
    }
  }

  /// Get user's documents
  static Future<List<Map<String, dynamic>>> getUserDocuments(
      String collectionName) async {
    try {
      if (!isAuthenticated) {
        return [];
      }

      final snapshot = await getCollection(collectionName)
          .where('userId', isEqualTo: currentUserId)
          .get();

      final results = snapshot.docs.map((doc) {
        final docData = doc.data() as Map<String, dynamic>;
        final data = {
          ...docData,
          'id': doc.id, // Ensure document ID overrides any existing id field
        };
        return data;
      }).toList();

      return results;
    } catch (e) {
      debugPrint('Error getting user documents from $collectionName: $e');
      return [];
    }
  }
}
