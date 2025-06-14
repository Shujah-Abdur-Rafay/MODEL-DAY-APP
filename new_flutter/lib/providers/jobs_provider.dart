import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/jobs_service.dart';

/// Provider for managing jobs state
class JobsProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';
  String _selectedStatus = 'all';
  String _sortOrder = 'date-desc';

  // Getters
  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;
  String get selectedStatus => _selectedStatus;
  String get sortOrder => _sortOrder;

  /// Get filtered and sorted jobs
  List<Job> get filteredJobs {
    var filtered = _jobs.where((job) {
      // Filter by search term
      if (_searchTerm.isNotEmpty) {
        final searchLower = _searchTerm.toLowerCase();
        final matchesSearch = job.clientName
                .toLowerCase()
                .contains(searchLower) ||
            job.type.toLowerCase().contains(searchLower) ||
            (job.location.toLowerCase().contains(searchLower)) ||
            (job.bookingAgent?.toLowerCase().contains(searchLower) ?? false);
        if (!matchesSearch) return false;
      }

      // Filter by status
      if (_selectedStatus != 'all') {
        if (job.status?.toLowerCase() != _selectedStatus) return false;
      }

      return true;
    }).toList();

    // Sort jobs
    switch (_sortOrder) {
      case 'date-asc':
        filtered.sort(
            (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
        break;
      case 'date-desc':
        filtered.sort(
            (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
        break;
      case 'client-asc':
        filtered.sort((a, b) => a.clientName.compareTo(b.clientName));
        break;
      case 'client-desc':
        filtered.sort((a, b) => b.clientName.compareTo(a.clientName));
        break;
      case 'rate-asc':
        filtered.sort((a, b) => a.rate.compareTo(b.rate));
        break;
      case 'rate-desc':
        filtered.sort((a, b) => b.rate.compareTo(a.rate));
        break;
    }

    return filtered;
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Set status filter and notify listeners
  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  /// Set sort order and notify listeners
  void setSortOrder(String order) {
    _sortOrder = order;
    notifyListeners();
  }

  /// Load all jobs
  Future<void> loadJobs() async {
    try {
      _setLoading(true);
      _error = null;

      final jobs = await JobsService.getJobs();

      _jobs = jobs;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load jobs: $e';
      _setLoading(false);
      debugPrint('Error loading jobs: $e');
    }
  }

  /// Create a new job
  Future<bool> createJob(Map<String, dynamic> jobData) async {
    try {
      _setLoading(true);

      final newJob = await JobsService.create(jobData);

      if (newJob != null) {
        await loadJobs();
        return true;
      } else {
        _error = 'Failed to create job';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating job: $e';
      _setLoading(false);
      debugPrint('Error creating job: $e');
      return false;
    }
  }

  /// Update an existing job
  Future<bool> updateJob(String id, Map<String, dynamic> jobData) async {
    try {
      _setLoading(true);

      final updatedJob = await JobsService.update(id, jobData);

      if (updatedJob != null) {
        await loadJobs();
        return true;
      } else {
        _error = 'Failed to update job';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating job: $e';
      _setLoading(false);
      debugPrint('Error updating job: $e');
      return false;
    }
  }

  /// Delete a job
  Future<bool> deleteJob(String id) async {
    try {
      _setLoading(true);

      final success = await JobsService.deleteJob(id);

      if (success) {
        await loadJobs();
        return true;
      } else {
        _error = 'Failed to delete job';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting job: $e';
      _setLoading(false);
      debugPrint('Error deleting job: $e');
      return false;
    }
  }

  /// Get a job by ID
  Job? getJobById(String id) {
    try {
      return _jobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a job by ID from the service (for editing)
  Future<Job?> getJobByIdFromService(String id) async {
    try {
      return await JobsService.get(id);
    } catch (e) {
      debugPrint('Error fetching job by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh jobs (for pull-to-refresh)
  Future<void> refresh() async {
    await loadJobs();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
