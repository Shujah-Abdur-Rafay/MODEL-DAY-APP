import 'package:flutter/foundation.dart';
import '../models/ai_job.dart';
import '../services/ai_jobs_service.dart';

/// Provider for managing AI jobs state
class AiJobsProvider extends ChangeNotifier {
  List<AiJob> _aiJobs = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<AiJob> get aiJobs => _aiJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  // Filtered AI jobs based on search term
  List<AiJob> get filteredAiJobs {
    if (_searchTerm.isEmpty) return _aiJobs;
    
    return _aiJobs.where((aiJob) {
      final searchLower = _searchTerm.toLowerCase();
      return aiJob.clientName.toLowerCase().contains(searchLower) ||
          (aiJob.type?.toLowerCase().contains(searchLower) ?? false) ||
          (aiJob.description?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Load all AI jobs
  Future<void> loadAiJobs() async {
    _setLoading(true);
    _setError(null);

    try {
      final aiJobs = await AiJobsService.list();
      _aiJobs = aiJobs;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load AI jobs: $e');
      debugPrint('Error loading AI jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new AI job
  Future<AiJob?> createAiJob(Map<String, dynamic> aiJobData) async {
    _setLoading(true);
    _setError(null);

    try {
      final aiJob = await AiJobsService.create(aiJobData);
      if (aiJob != null) {
        _aiJobs.add(aiJob);
        notifyListeners();
      }
      return aiJob;
    } catch (e) {
      _setError('Failed to create AI job: $e');
      debugPrint('Error creating AI job: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing AI job
  Future<AiJob?> updateAiJob(String id, Map<String, dynamic> aiJobData) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedAiJob = await AiJobsService.update(id, aiJobData);
      if (updatedAiJob != null) {
        final index = _aiJobs.indexWhere((aj) => aj.id == id);
        if (index != -1) {
          _aiJobs[index] = updatedAiJob;
          notifyListeners();
        }
      }
      return updatedAiJob;
    } catch (e) {
      _setError('Failed to update AI job: $e');
      debugPrint('Error updating AI job: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an AI job
  Future<bool> deleteAiJob(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await AiJobsService.delete(id);
      if (success) {
        _aiJobs.removeWhere((aj) => aj.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete AI job: $e');
      debugPrint('Error deleting AI job: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get an AI job by ID
  Future<AiJob?> getAiJobById(String id) async {
    try {
      return await AiJobsService.getById(id);
    } catch (e) {
      _setError('Failed to get AI job: $e');
      debugPrint('Error getting AI job: $e');
      return null;
    }
  }

  /// Set search term and filter AI jobs
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Clear search term
  void clearSearch() {
    _searchTerm = '';
    notifyListeners();
  }

  /// Refresh AI jobs
  Future<void> refresh() async {
    await loadAiJobs();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _aiJobs.clear();
    _searchTerm = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
