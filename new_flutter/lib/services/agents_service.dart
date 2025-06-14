import 'package:flutter/foundation.dart';
import '../models/agent.dart';
import 'firebase_service_template.dart';

class AgentsService {
  static const String _collectionName = 'agents';

  Future<List<Agent>> getAgents() async {
    try {
      final documents = await FirebaseServiceTemplate.getUserDocuments(_collectionName);
      return documents.map<Agent>((doc) => Agent.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching agents: $e');
      return [];
    }
  }

  Future<Agent?> createAgent(Map<String, dynamic> agentData) async {
    try {
      final docId = await FirebaseServiceTemplate.createDocument(_collectionName, agentData);
      if (docId != null) {
        final doc = await FirebaseServiceTemplate.getDocument(_collectionName, docId);
        if (doc != null) {
          return Agent.fromJson(doc);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating agent: $e');
      return null;
    }
  }

  Future<Agent?> getAgentById(String id) async {
    try {
      final doc = await FirebaseServiceTemplate.getDocument(_collectionName, id);
      if (doc != null) {
        return Agent.fromJson(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching agent: $e');
      return null;
    }
  }

  Future<Agent?> updateAgent(String id, Agent agent) async {
    try {
      final agentData = agent.toJson();
      final success = await FirebaseServiceTemplate.updateDocument(_collectionName, id, agentData);
      if (success) {
        return await getAgentById(id);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating agent: $e');
      return null;
    }
  }

  Future<bool> deleteAgent(String id) async {
    try {
      return await FirebaseServiceTemplate.deleteDocument(_collectionName, id);
    } catch (e) {
      debugPrint('Error deleting agent: $e');
      return false;
    }
  }
}
