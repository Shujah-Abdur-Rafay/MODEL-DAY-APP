import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/events_service.dart';

/// Provider for managing events state
class EventsProvider extends ChangeNotifier {
  final EventsService _eventsService = EventsService();

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  /// Get filtered events based on search term
  List<Event> get filteredEvents {
    if (_searchTerm.isEmpty) {
      return _events;
    }

    final searchLower = _searchTerm.toLowerCase();
    return _events.where((event) {
      return (event.clientName?.toLowerCase().contains(searchLower) ?? false) ||
          (event.notes?.toLowerCase().contains(searchLower) ?? false) ||
          (event.location?.toLowerCase().contains(searchLower) ?? false) ||
          event.type.displayName.toLowerCase().contains(searchLower);
    }).toList();
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Load all events
  Future<void> loadEvents() async {
    try {
      _setLoading(true);
      _error = null;

      final events = await _eventsService.getEvents();
      events.sort((a, b) => (a.clientName ?? '').compareTo(b.clientName ?? ''));

      _events = events;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load events: $e';
      _setLoading(false);
      debugPrint('Error loading events: $e');
    }
  }

  /// Create a new event
  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    try {
      _setLoading(true);

      final newEvent = await _eventsService.createEvent(eventData);

      if (newEvent != null) {
        await loadEvents();
        return true;
      } else {
        _error = 'Failed to create event';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating event: $e';
      _setLoading(false);
      debugPrint('Error creating event: $e');
      return false;
    }
  }

  /// Update an existing event
  Future<bool> updateEvent(String id, Map<String, dynamic> eventData) async {
    try {
      _setLoading(true);

      final updatedEvent = await _eventsService.updateEvent(id, eventData);

      if (updatedEvent != null) {
        await loadEvents();
        return true;
      } else {
        _error = 'Failed to update event';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating event: $e';
      _setLoading(false);
      debugPrint('Error updating event: $e');
      return false;
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String id) async {
    try {
      _setLoading(true);

      final success = await _eventsService.deleteEvent(id);

      if (success) {
        await loadEvents();
        return true;
      } else {
        _error = 'Failed to delete event';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting event: $e';
      _setLoading(false);
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  /// Get an event by ID
  Event? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get an event by ID from the service (for editing)
  Future<Event?> getEventByIdFromService(String id) async {
    try {
      return await _eventsService.getEventById(id);
    } catch (e) {
      debugPrint('Error fetching event by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh events (for pull-to-refresh)
  Future<void> refresh() async {
    await loadEvents();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
