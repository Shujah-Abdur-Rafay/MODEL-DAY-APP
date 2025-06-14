import 'package:flutter/foundation.dart';
import '../models/agent.dart';
import '../services/agents_service.dart';

/// Provider for managing agents state
class AgentsProvider extends ChangeNotifier {
  final AgentsService _agentsService = AgentsService();
  
  List<Agent> _agents = [];
  bool _isLoading = false;
  String? _error;
  String _searchTerm = '';

  // Getters
  List<Agent> get agents => _agents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;

  /// Get filtered agents based on search term
  List<Agent> get filteredAgents {
    if (_searchTerm.isEmpty) {
      return _agents;
    }
    
    final searchLower = _searchTerm.toLowerCase();
    return _agents.where((agent) {
      return agent.name.toLowerCase().contains(searchLower) ||
          (agent.email?.toLowerCase().contains(searchLower) ?? false) ||
          (agent.phone?.toLowerCase().contains(searchLower) ?? false) ||
          (agent.city?.toLowerCase().contains(searchLower) ?? false) ||
          (agent.country?.toLowerCase().contains(searchLower) ?? false) ||
          (agent.agency?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  }

  /// Set search term and notify listeners
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Load all agents
  Future<void> loadAgents() async {
    try {
      _setLoading(true);
      _error = null;

      final agents = await _agentsService.getAgents();
      agents.sort((a, b) => a.name.compareTo(b.name));

      _agents = agents;
      _setLoading(false);
    } catch (e) {
      _error = 'Failed to load agents: $e';
      _setLoading(false);
      debugPrint('Error loading agents: $e');
    }
  }

  /// Create a new agent
  Future<bool> createAgent(Map<String, dynamic> agentData) async {
    try {
      _setLoading(true);
      
      final newAgent = await _agentsService.createAgent(agentData);
      
      if (newAgent != null) {
        await loadAgents();
        return true;
      } else {
        _error = 'Failed to create agent';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error creating agent: $e';
      _setLoading(false);
      debugPrint('Error creating agent: $e');
      return false;
    }
  }

  /// Update an existing agent
  Future<bool> updateAgent(String id, Agent agent) async {
    try {
      _setLoading(true);
      
      final updatedAgent = await _agentsService.updateAgent(id, agent);
      
      if (updatedAgent != null) {
        await loadAgents();
        return true;
      } else {
        _error = 'Failed to update agent';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error updating agent: $e';
      _setLoading(false);
      debugPrint('Error updating agent: $e');
      return false;
    }
  }

  /// Delete an agent
  Future<bool> deleteAgent(String id) async {
    try {
      _setLoading(true);
      
      final success = await _agentsService.deleteAgent(id);
      
      if (success) {
        await loadAgents();
        return true;
      } else {
        _error = 'Failed to delete agent';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Error deleting agent: $e';
      _setLoading(false);
      debugPrint('Error deleting agent: $e');
      return false;
    }
  }

  /// Get an agent by ID
  Agent? getAgentById(String id) {
    try {
      return _agents.firstWhere((agent) => agent.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get an agent by ID from the service (for editing)
  Future<Agent?> getAgentByIdFromService(String id) async {
    try {
      return await _agentsService.getAgentById(id);
    } catch (e) {
      debugPrint('Error fetching agent by ID from service: $e');
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh agents (for pull-to-refresh)
  Future<void> refresh() async {
    await loadAgents();
  }

  /// Private method to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
