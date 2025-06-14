import 'package:flutter/foundation.dart';
import '../models/industry_contact.dart';
import '../services/industry_contacts_service.dart';

/// Provider for managing industry contacts state
class IndustryContactsProvider extends ChangeNotifier {
  final IndustryContactsService _contactsService = IndustryContactsService();

  List<IndustryContact> _contacts = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<IndustryContact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  /// Get filtered contacts based on search term
  List<IndustryContact> get filteredContacts {
    if (_searchTerm.isEmpty) {
      return _contacts;
    }

    final searchLower = _searchTerm.toLowerCase();
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(searchLower) ||
          (contact.company?.toLowerCase().contains(searchLower) ?? false) ||
          (contact.email?.toLowerCase().contains(searchLower) ?? false) ||
          (contact.jobTitle?.toLowerCase().contains(searchLower) ?? false) ||
          (contact.city?.toLowerCase().contains(searchLower) ?? false) ||
          (contact.country?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Load all contacts
  Future<void> loadContacts() async {
    try {
      _setLoading(true);
      _error = null;
      final contacts = await _contactsService.getIndustryContacts();
      contacts.sort((a, b) => a.name.compareTo(b.name));

      _contacts = contacts;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load industry contacts: $e';
      _setLoading(false);
      debugPrint('❌ Error loading contacts: $e');
    }
  }

  /// Create a new contact
  Future<bool> createContact(Map<String, dynamic> contactData) async {
    try {
      _setLoading(true);

      final newContact =
          await _contactsService.createIndustryContact(contactData);

      if (newContact != null) {
        // Reload all contacts to ensure we have the latest data with proper IDs
        await loadContacts();
        return true;
      } else {
        _error = 'Failed to create contact';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating contact: $e';
      _setLoading(false);
      debugPrint('Error creating contact: $e');
      return false;
    }
  }

  /// Update an existing contact
  Future<bool> updateContact(
      String id, Map<String, dynamic> contactData) async {
    try {
      _setLoading(true);

      final updatedContact =
          await _contactsService.updateIndustryContact(id, contactData);

      if (updatedContact != null) {
        // Reload all contacts to ensure we have the latest data
        await loadContacts();
        return true;
      } else {
        _error = 'Failed to update contact';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating contact: $e';
      _setLoading(false);
      debugPrint('Error updating contact: $e');
      return false;
    }
  }

  /// Delete a contact
  Future<bool> deleteContact(String id) async {
    try {
      _setLoading(true);

      final success = await _contactsService.deleteIndustryContact(id);

      if (success) {
        // Reload all contacts to ensure we have the latest data
        await loadContacts();
        return true;
      } else {
        _error = 'Failed to delete contact';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting contact: $e';
      _setLoading(false);
      debugPrint('Error deleting contact: $e');
      return false;
    }
  }

  /// Get a contact by ID
  IndustryContact? getContactById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      debugPrint('Contact with ID $id not found in local list');
      return null;
    }
  }

  /// Get a contact by ID from the service (for editing)
  Future<IndustryContact?> getContactByIdFromService(String id) async {
    try {
      return await _contactsService.getIndustryContactById(id);
    } catch (e) {
      debugPrint('Error fetching contact by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh contacts (for pull-to-refresh)
  Future<void> refresh() async {
    await loadContacts();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
