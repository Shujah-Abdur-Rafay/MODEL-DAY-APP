import 'package:flutter/foundation.dart';
import '../models/casting.dart';

/// Provider for managing castings state
class CastingsProvider extends ChangeNotifier {
  List<Casting> _castings = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<Casting> get castings => _castings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  /// Get filtered castings based on search term
  List<Casting> get filteredCastings {
    if (_searchTerm.isEmpty) {
      return _castings;
    }
    
    final searchLower = _searchTerm.toLowerCase();
    return _castings.where((casting) {
      return casting.title.toLowerCase().contains(searchLower) ||
          (casting.description?.toLowerCase().contains(searchLower) ?? false) ||
          (casting.location?.toLowerCase().contains(searchLower) ?? false) ||
          (casting.requirements?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Load all castings
  Future<void> loadCastings() async {
    try {
      debugPrint('🔍 CastingsProvider.loadCastings() - Starting to load castings');
      _setLoading(true);
      _error = null;

      final castings = await Casting.list();
      debugPrint('🔍 CastingsProvider.loadCastings() - Loaded ${castings.length} castings');
      castings.sort((a, b) => b.date.compareTo(a.date));

      _castings = castings;
      debugPrint('🔍 CastingsProvider.loadCastings() - Set ${_castings.length} castings in provider');
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load castings: $e';
      _setLoading(false);
      debugPrint('❌ Error loading castings: $e');
    }
  }

  /// Create a new casting
  Future<bool> createCasting(Map<String, dynamic> castingData) async {
    try {
      _setLoading(true);
      
      final newCasting = await Casting.create(castingData);
      
      if (newCasting != null) {
        await loadCastings();
        return true;
      } else {
        _error = 'Failed to create casting';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating casting: $e';
      _setLoading(false);
      debugPrint('Error creating casting: $e');
      return false;
    }
  }

  /// Update an existing casting
  Future<bool> updateCasting(String id, Map<String, dynamic> castingData) async {
    try {
      _setLoading(true);
      
      final updatedCasting = await Casting.update(id, castingData);
      
      if (updatedCasting != null) {
        await loadCastings();
        return true;
      } else {
        _error = 'Failed to update casting';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating casting: $e';
      _setLoading(false);
      debugPrint('Error updating casting: $e');
      return false;
    }
  }

  /// Delete a casting
  Future<bool> deleteCasting(String id) async {
    try {
      _setLoading(true);
      
      final success = await Casting.delete(id);
      
      if (success) {
        await loadCastings();
        return true;
      } else {
        _error = 'Failed to delete casting';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting casting: $e';
      _setLoading(false);
      debugPrint('Error deleting casting: $e');
      return false;
    }
  }

  /// Get a casting by ID
  Casting? getCastingById(String id) {
    try {
      return _castings.firstWhere((casting) => casting.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a casting by ID from the service (for editing)
  Future<Casting?> getCastingByIdFromService(String id) async {
    try {
      return await Casting.get(id);
    } catch (e) {
      debugPrint('Error fetching casting by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh castings (for pull-to-refresh)
  Future<void> refresh() async {
    await loadCastings();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
