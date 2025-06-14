import 'package:flutter/foundation.dart';
import '../models/test.dart';

/// Provider for managing tests state
class TestsProvider extends ChangeNotifier {
  List<Test> _tests = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<Test> get tests => _tests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  /// Get filtered tests based on search term
  List<Test> get filteredTests {
    if (_searchTerm.isEmpty) {
      return _tests;
    }
    
    final searchLower = _searchTerm.toLowerCase();
    return _tests.where((test) {
      return test.title.toLowerCase().contains(searchLower) ||
          (test.description?.toLowerCase().contains(searchLower) ?? false) ||
          (test.location?.toLowerCase().contains(searchLower) ?? false) ||
          (test.requirements?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Load all tests
  Future<void> loadTests() async {
    try {
      debugPrint('🧪 TestsProvider.loadTests() - Starting to load tests');
      _setLoading(true);
      _error = null;

      final tests = await Test.list();
      debugPrint('🧪 TestsProvider.loadTests() - Loaded ${tests.length} tests');
      tests.sort((a, b) => b.date.compareTo(a.date));

      for (var test in tests) {
        debugPrint('🧪 Test: ${test.title} (${test.id})');
      }

      _tests = tests;
      _setLoading(false);
      debugPrint('🧪 TestsProvider.loadTests() - Finished loading tests');
    } catch (e) {
      _error = 'Failed to load tests: $e';
      _setLoading(false);
      debugPrint('🧪 Error loading tests: $e');
    }
  }

  /// Create a new test
  Future<bool> createTest(Map<String, dynamic> testData) async {
    try {
      _setLoading(true);
      
      final newTest = await Test.create(testData);
      
      if (newTest != null) {
        await loadTests();
        return true;
      } else {
        _error = 'Failed to create test';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating test: $e';
      _setLoading(false);
      debugPrint('Error creating test: $e');
      return false;
    }
  }

  /// Update an existing test
  Future<bool> updateTest(String id, Map<String, dynamic> testData) async {
    try {
      _setLoading(true);
      
      final updatedTest = await Test.update(id, testData);
      
      if (updatedTest != null) {
        await loadTests();
        return true;
      } else {
        _error = 'Failed to update test';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating test: $e';
      _setLoading(false);
      debugPrint('Error updating test: $e');
      return false;
    }
  }

  /// Delete a test
  Future<bool> deleteTest(String id) async {
    try {
      _setLoading(true);
      
      final success = await Test.delete(id);
      
      if (success) {
        await loadTests();
        return true;
      } else {
        _error = 'Failed to delete test';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting test: $e';
      _setLoading(false);
      debugPrint('Error deleting test: $e');
      return false;
    }
  }

  /// Get a test by ID
  Test? getTestById(String id) {
    try {
      return _tests.firstWhere((test) => test.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a test by ID from the service (for editing)
  Future<Test?> getTestByIdFromService(String id) async {
    try {
      return await Test.get(id);
    } catch (e) {
      debugPrint('Error fetching test by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh tests (for pull-to-refresh)
  Future<void> refresh() async {
    await loadTests();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
