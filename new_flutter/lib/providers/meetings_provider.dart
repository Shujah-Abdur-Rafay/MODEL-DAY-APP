import 'package:flutter/foundation.dart';
import '../models/meeting.dart';
import '../services/meetings_service.dart';

/// Provider for managing meetings state
class MeetingsProvider extends ChangeNotifier {
  List<Meeting> _meetings = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<Meeting> get meetings => _meetings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  // Filtered meetings based on search term
  List<Meeting> get filteredMeetings {
    if (_searchTerm.isEmpty) return _meetings;
    
    return _meetings.where((meeting) {
      final searchLower = _searchTerm.toLowerCase();
      return meeting.clientName.toLowerCase().contains(searchLower) ||
          (meeting.type?.toLowerCase().contains(searchLower) ?? false) ||
          (meeting.location?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Load all meetings
  Future<void> loadMeetings() async {
    _setLoading(true);
    _setError(null);

    try {
      final meetings = await MeetingsService.list();
      _meetings = meetings;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load meetings: $e');
      debugPrint('Error loading meetings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new meeting
  Future<Meeting?> createMeeting(Map<String, dynamic> meetingData) async {
    _setLoading(true);
    _setError(null);

    try {
      final meeting = await MeetingsService.createMeeting(meetingData);
      if (meeting != null) {
        _meetings.add(meeting);
        notifyListeners();
      }
      return meeting;
    } catch (e) {
      _setError('Failed to create meeting: $e');
      debugPrint('Error creating meeting: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing meeting
  Future<Meeting?> updateMeeting(String id, Map<String, dynamic> meetingData) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedMeeting = await MeetingsService.updateMeeting(id, meetingData);
      if (updatedMeeting != null) {
        final index = _meetings.indexWhere((m) => m.id == id);
        if (index != -1) {
          _meetings[index] = updatedMeeting;
          notifyListeners();
        }
      }
      return updatedMeeting;
    } catch (e) {
      _setError('Failed to update meeting: $e');
      debugPrint('Error updating meeting: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a meeting
  Future<bool> deleteMeeting(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await MeetingsService.delete(id);
      if (success) {
        _meetings.removeWhere((m) => m.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete meeting: $e');
      debugPrint('Error deleting meeting: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get a meeting by ID
  Future<Meeting?> getMeetingById(String id) async {
    try {
      return await MeetingsService.getMeetingById(id);
    } catch (e) {
      _setError('Failed to get meeting: $e');
      debugPrint('Error getting meeting: $e');
      return null;
    }
  }

  /// Set search term and filter meetings
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Clear search term
  void clearSearch() {
    _searchTerm = '';
    notifyListeners();
  }

  /// Refresh meetings
  Future<void> refresh() async {
    await loadMeetings();
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
    _meetings.clear();
    _searchTerm = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
