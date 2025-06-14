import 'package:flutter/foundation.dart';
import '../models/polaroid.dart';
import '../services/polaroids_service.dart';

/// Provider for managing polaroids state
class PolaroidsProvider extends ChangeNotifier {
  List<Polaroid> _polaroids = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<Polaroid> get polaroids => _polaroids;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  /// Get filtered polaroids based on search term
  List<Polaroid> get filteredPolaroids {
    if (_searchTerm.isEmpty) {
      return _polaroids;
    }

    final searchLower = _searchTerm.toLowerCase();
    return _polaroids.where((polaroid) {
      return polaroid.clientName.toLowerCase().contains(searchLower) ||
          (polaroid.type?.toLowerCase().contains(searchLower) ?? false) ||
          (polaroid.location?.toLowerCase().contains(searchLower) ?? false) ||
          (polaroid.notes?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Load all polaroids
  Future<void> loadPolaroids() async {
    try {
      _setLoading(true);
      _error = null;

      final polaroids = await PolaroidsService.getPolaroids();
      polaroids.sort(
          (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

      _polaroids = polaroids;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load polaroids: $e';
      _setLoading(false);
      debugPrint('Error loading polaroids: $e');
    }
  }

  /// Create a new polaroid
  Future<bool> createPolaroid(Map<String, dynamic> polaroidData) async {
    try {
      _setLoading(true);

      final newPolaroid = await PolaroidsService.createPolaroid(polaroidData);

      if (newPolaroid != null) {
        await loadPolaroids();
        return true;
      } else {
        _error = 'Failed to create polaroid';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating polaroid: $e';
      _setLoading(false);
      debugPrint('Error creating polaroid: $e');
      return false;
    }
  }

  /// Update an existing polaroid
  Future<bool> updatePolaroid(
      String id, Map<String, dynamic> polaroidData) async {
    try {
      _setLoading(true);

      final updatedPolaroid =
          await PolaroidsService.updatePolaroid(id, polaroidData);

      if (updatedPolaroid != null) {
        await loadPolaroids();
        return true;
      } else {
        _error = 'Failed to update polaroid';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating polaroid: $e';
      _setLoading(false);
      debugPrint('Error updating polaroid: $e');
      return false;
    }
  }

  /// Delete a polaroid
  Future<bool> deletePolaroid(String id) async {
    try {
      _setLoading(true);

      final success = await PolaroidsService.delete(id);

      if (success) {
        await loadPolaroids();
        return true;
      } else {
        _error = 'Failed to delete polaroid';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting polaroid: $e';
      _setLoading(false);
      debugPrint('Error deleting polaroid: $e');
      return false;
    }
  }

  /// Get a polaroid by ID
  Polaroid? getPolaroidById(String id) {
    try {
      return _polaroids.firstWhere((polaroid) => polaroid.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a polaroid by ID from the service (for editing)
  Future<Polaroid?> getPolaroidByIdFromService(String id) async {
    try {
      return await PolaroidsService.getPolaroidById(id);
    } catch (e) {
      debugPrint('Error fetching polaroid by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh polaroids (for pull-to-refresh)
  Future<void> refresh() async {
    await loadPolaroids();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
