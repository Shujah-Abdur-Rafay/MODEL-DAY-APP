import 'package:flutter/foundation.dart';
import '../models/agency.dart';
import '../services/agencies_service.dart';

/// Provider for managing agencies state
class AgenciesProvider extends ChangeNotifier {
  List<Agency> _agencies = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<Agency> get agencies => _agencies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  /// Get filtered agencies based on search term
  List<Agency> get filteredAgencies {
    if (_searchTerm.isEmpty) {
      return _agencies;
    }

    final searchLower = _searchTerm.toLowerCase();
    return _agencies.where((agency) {
      return agency.name.toLowerCase().contains(searchLower) ||
          (agency.mainBooker?.email.toLowerCase().contains(searchLower) ??
              false) ||
          (agency.mainBooker?.phone.toLowerCase().contains(searchLower) ??
              false) ||
          (agency.city?.toLowerCase().contains(searchLower) ?? false) ||
          (agency.country?.toLowerCase().contains(searchLower) ?? false) ||
          (agency.website?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Load all agencies
  Future<void> loadAgencies() async {
    try {
      _setLoading(true);
      _error = null;

      final agencies = await AgenciesService.list();
      agencies.sort((a, b) => a.name.compareTo(b.name));

      _agencies = agencies;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load agencies: $e';
      _setLoading(false);
      debugPrint('Error loading agencies: $e');
    }
  }

  /// Create a new agency
  Future<bool> createAgency(Map<String, dynamic> agencyData) async {
    try {
      _setLoading(true);

      final newAgency = await AgenciesService.create(agencyData);

      if (newAgency != null) {
        await loadAgencies();
        return true;
      } else {
        _error = 'Failed to create agency';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating agency: $e';
      _setLoading(false);
      debugPrint('Error creating agency: $e');
      return false;
    }
  }

  /// Update an existing agency
  Future<bool> updateAgency(String id, Map<String, dynamic> agencyData) async {
    try {
      _setLoading(true);

      final updatedAgency = await AgenciesService.update(id, agencyData);

      if (updatedAgency != null) {
        await loadAgencies();
        return true;
      } else {
        _error = 'Failed to update agency';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating agency: $e';
      _setLoading(false);
      debugPrint('Error updating agency: $e');
      return false;
    }
  }

  /// Delete an agency
  Future<bool> deleteAgency(String id) async {
    try {
      _setLoading(true);

      final success = await AgenciesService.delete(id);

      if (success) {
        await loadAgencies();
        return true;
      } else {
        _error = 'Failed to delete agency';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting agency: $e';
      _setLoading(false);
      debugPrint('Error deleting agency: $e');
      return false;
    }
  }

  /// Get an agency by ID
  Agency? getAgencyById(String id) {
    try {
      return _agencies.firstWhere((agency) => agency.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get an agency by ID from the service (for editing)
  Future<Agency?> getAgencyByIdFromService(String id) async {
    try {
      return await AgenciesService.getById(id);
    } catch (e) {
      debugPrint('Error fetching agency by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh agencies (for pull-to-refresh)
  Future<void> refresh() async {
    await loadAgencies();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
