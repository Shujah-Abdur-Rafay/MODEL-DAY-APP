import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/events_service.dart';

/// Provider for managing other events state
class OtherEventsProvider extends ChangeNotifier {
  List<Event> _otherEvents = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';
  final EventsService _eventsService = EventsService();

  // Getters
  List<Event> get otherEvents => _otherEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  // Filtered other events based on search term
  List<Event> get filteredOtherEvents {
    if (_searchTerm.isEmpty) return _otherEvents;
    
    return _otherEvents.where((event) {
      final searchLower = _searchTerm.toLowerCase();
      return (event.clientName?.toLowerCase().contains(searchLower) ?? false) ||
          (event.location?.toLowerCase().contains(searchLower) ?? false) ||
          (event.notes?.toLowerCase().contains(searchLower) ?? false) ||
          (event.additionalData?['event_name']?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Load all other events
  Future<void> loadOtherEvents() async {
    _setLoading(true);
    _setError(null);

    try {
      final allEvents = await _eventsService.getEvents();
      final otherEvents = allEvents.where((event) => event.type == EventType.other).toList();
      _otherEvents = otherEvents;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load other events: $e');
      debugPrint('Error loading other events: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new other event
  Future<Event?> createOtherEvent(Map<String, dynamic> eventData) async {
    _setLoading(true);
    _setError(null);

    try {
      final event = await _eventsService.createEvent(eventData);
      if (event != null && event.type == EventType.other) {
        _otherEvents.add(event);
        notifyListeners();
      }
      return event;
    } catch (e) {
      _setError('Failed to create other event: $e');
      debugPrint('Error creating other event: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing other event
  Future<Event?> updateOtherEvent(String id, Map<String, dynamic> eventData) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedEvent = await _eventsService.updateEvent(id, eventData);
      if (updatedEvent != null) {
        final index = _otherEvents.indexWhere((e) => e.id == id);
        if (index != -1) {
          _otherEvents[index] = updatedEvent;
          notifyListeners();
        }
      }
      return updatedEvent;
    } catch (e) {
      _setError('Failed to update other event: $e');
      debugPrint('Error updating other event: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an other event
  Future<bool> deleteOtherEvent(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _eventsService.deleteEvent(id);
      if (success) {
        _otherEvents.removeWhere((e) => e.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete other event: $e');
      debugPrint('Error deleting other event: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get an other event by ID
  Future<Event?> getOtherEventById(String id) async {
    try {
      return await _eventsService.getEventById(id);
    } catch (e) {
      _setError('Failed to get other event: $e');
      debugPrint('Error getting other event: $e');
      return null;
    }
  }

  /// Set search term and filter other events
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Clear search term
  void clearSearch() {
    _searchTerm = '';
    notifyListeners();
  }

  /// Refresh other events
  Future<void> refresh() async {
    await loadOtherEvents();
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
    _otherEvents.clear();
    _searchTerm = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
