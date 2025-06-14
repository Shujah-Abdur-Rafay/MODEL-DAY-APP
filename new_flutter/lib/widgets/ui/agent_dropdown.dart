import 'package:flutter/material.dart';
import '../../models/agent.dart';
import '../../services/agents_service.dart';

class AgentDropdown extends StatefulWidget {
  final String? selectedAgentId;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool showAddButton;

  const AgentDropdown({
    super.key,
    this.selectedAgentId,
    this.labelText = 'Booking Agent',
    this.hintText = 'Select an agent',
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.showAddButton = true,
  });

  @override
  State<AgentDropdown> createState() => _AgentDropdownState();
}

class _AgentDropdownState extends State<AgentDropdown> {
  List<Agent> _agents = [];
  bool _isLoading = true;
  String? _currentValue;
  final AgentsService _agentsService = AgentsService();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.selectedAgentId;
    _loadAgents();
  }

  @override
  void didUpdateWidget(AgentDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAgentId != widget.selectedAgentId) {
      _updateCurrentValue();
    }
  }

  void _updateCurrentValue() {
    // Use the same safe logic as the dropdown
    final validAgentIds = _getValidAgentIds();
    final isValidValue = widget.selectedAgentId != null &&
        widget.selectedAgentId!.isNotEmpty &&
        validAgentIds.contains(widget.selectedAgentId);

    setState(() {
      _currentValue = isValidValue ? widget.selectedAgentId : null;
    });
  }

  Future<void> _loadAgents() async {
    try {
      final agents = await _agentsService.getAgents();
      debugPrint('AgentDropdown: Loaded ${agents.length} agents from service');

      if (mounted) {
        setState(() {
          // Store all agents, we'll handle filtering in the dropdown items
          _agents = agents;
          _isLoading = false;
        });

        debugPrint('AgentDropdown: Set ${_agents.length} agents in state');
        for (var agent in _agents) {
          debugPrint(
              'AgentDropdown: Agent - id: ${agent.id}, name: ${agent.name}');
        }

        // Update current value after loading agents to ensure it's valid
        _updateCurrentValue();
      }
    } catch (e) {
      debugPrint('Error loading agents: $e');
      if (mounted) {
        setState(() {
          _agents = []; // Ensure we have an empty list on error
          _isLoading = false;
          _currentValue = null; // Clear current value on error
        });
      }
    }
  }

  Future<void> _createNewAgent() async {
    final result = await Navigator.pushNamed(context, '/new-agent');
    if (result != null && result is String && result.isNotEmpty) {
      // Reload agents after creating new one
      await _loadAgents();
      // Select the newly created agent only if it exists in the valid agents list
      final validAgentIds = _getValidAgentIds();
      if (validAgentIds.contains(result)) {
        setState(() {
          _currentValue = result;
        });
        widget.onChanged?.call(result);
      }
    }
  }

  Widget _buildDropdownField() {
    return _isLoading
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[900],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Loading agents...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[900],
            ),
            child: DropdownButtonFormField<String>(
              value: _getSafeDropdownValue(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              hint: Text(
                widget.hintText ?? 'Select an agent',
                style: TextStyle(color: Colors.grey[400]),
                overflow: TextOverflow.ellipsis,
              ),
              isExpanded: true, // This prevents overflow
              items: _buildSafeDropdownItems(),
              onChanged: widget.enabled ? _handleDropdownChange : null,
              validator: widget.validator,
            ),
          );
  }

  String? _getSafeDropdownValue() {
    debugPrint(
        'AgentDropdown: Getting safe dropdown value for: $_currentValue');

    // Return null if no current value or agents list is empty
    if (_currentValue == null || _agents.isEmpty) {
      debugPrint('AgentDropdown: No current value or empty agents list');
      return null;
    }

    // Check if current value exists in any agent (by ID or name)
    final hasMatchingAgent = _agents.any(
        (agent) => agent.id == _currentValue || agent.name == _currentValue);

    debugPrint('AgentDropdown: Has matching agent: $hasMatchingAgent');
    return hasMatchingAgent ? _currentValue : null;
  }

  List<String> _getValidAgentIds() {
    final validIds = _agents
        .where((agent) => agent.id != null && agent.id!.isNotEmpty)
        .map((agent) => agent.id!)
        .toList();

    debugPrint('AgentDropdown: Valid agent IDs: $validIds');
    return validIds;
  }

  List<DropdownMenuItem<String>> _buildSafeDropdownItems() {
    debugPrint(
        'AgentDropdown: Building dropdown items for ${_agents.length} agents');

    if (_agents.isEmpty) {
      debugPrint('AgentDropdown: No agents available, showing placeholder');
      // Return a single disabled item when no agents are available
      return [
        DropdownMenuItem<String>(
          value: null,
          enabled: false,
          child: Text(
            'No agents available',
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ];
    }

    // Build dropdown items for all agents (even those with null IDs for now)
    final items = _agents.map((agent) {
      // Use agent name as fallback ID if id is null (temporary for debugging)
      final agentId = agent.id ?? agent.name;
      debugPrint(
          'AgentDropdown: Creating item for agent - id: $agentId, name: ${agent.name}');

      return DropdownMenuItem<String>(
        value: agentId,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final displayText = agent.name.isNotEmpty ? agent.name : 'Unnamed Agent';
            final agencyText = agent.agency != null && agent.agency!.isNotEmpty
                ? ' (${agent.agency!})'
                : '';
            final fullText = '$displayText$agencyText';

            return SizedBox(
              width: constraints.maxWidth,
              child: Text(
                fullText,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          },
        ),
      );
    }).toList();

    debugPrint('AgentDropdown: Created ${items.length} dropdown items');
    return items;
  }

  void _handleDropdownChange(String? value) {
    debugPrint('AgentDropdown: Handling dropdown change to: $value');

    // Only process valid values
    if (value == null) {
      setState(() {
        _currentValue = null;
      });
      widget.onChanged?.call(null);
      return;
    }

    // Find the agent that matches this value (by ID or name)
    final matchingAgent = _agents.firstWhere(
      (agent) => agent.id == value || agent.name == value,
      orElse: () => Agent(name: ''), // Return empty agent if not found
    );

    if (matchingAgent.name.isNotEmpty) {
      // Use the agent's actual ID if available, otherwise use the value
      final agentId = matchingAgent.id ?? value;
      debugPrint(
          'AgentDropdown: Selected agent ID: $agentId, name: ${matchingAgent.name}');

      setState(() {
        _currentValue = agentId;
      });
      widget.onChanged?.call(agentId);
    } else {
      // If somehow an invalid value was selected, clear it
      debugPrint('AgentDropdown: Invalid value selected, clearing');
      setState(() {
        _currentValue = null;
      });
      widget.onChanged?.call(null);
    }
  }

  Widget _buildPlusButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.withValues(alpha: 0.1),
      ),
      child: IconButton(
        onPressed: widget.enabled ? _createNewAgent : null,
        icon: const Icon(
          Icons.add,
          color: Colors.blue,
          size: 20,
        ),
        tooltip: 'Create New Agent',
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
        minWidth: 150, // Ensure minimum width
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.labelText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Determine layout based on available width
              final availableWidth = constraints.maxWidth;
              final isVerySmall = availableWidth < 200; // Reduced threshold
              final hasAddButton = widget.showAddButton;

              // Always use vertical layout if space is too constrained or no add button
              if (isVerySmall || !hasAddButton) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDropdownField(),
                    if (hasAddButton) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildPlusButton(),
                      ),
                    ],
                  ],
                );
              } else {
                // Use row layout for larger screens with add button
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildDropdownField(),
                      ),
                      const SizedBox(width: 8),
                      _buildPlusButton(),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
