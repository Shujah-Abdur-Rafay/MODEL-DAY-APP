import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/button.dart' as ui;
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/card.dart' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/agent.dart';
import '../providers/agents_provider.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({super.key});

  @override
  State<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentsProvider>().loadAgents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showDeleteConfirmation(Agent agent) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Agent',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${agent.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAgent(agent);
    }
  }

  Future<void> _deleteAgent(Agent agent) async {
    final provider = context.read<AgentsProvider>();
    final success = await provider.deleteAgent(agent.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Agent deleted successfully'
              : provider.error ?? 'Error deleting agent'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Widget _buildAgentCard(Agent agent) {
    return ui.Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Colors.white,
                        ),
                      ),
                      if (agent.agency != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              agent.agency!,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/new-agent',
                          arguments: agent.id,
                        );
                        if (result == true && mounted) {
                          context.read<AgentsProvider>().loadAgents();
                        }
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _showDeleteConfirmation(agent);
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (agent.email != null || agent.phone != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (agent.email != null) ...[
                      InkWell(
                        onTap: () => _launchUrl('mailto:${agent.email}'),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mail_outline,
                              size: 16,
                              color: Colors.blue[300],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              agent.email!,
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (agent.phone != null) ...[
                      if (agent.email != null) const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl('tel:${agent.phone}'),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: Colors.blue[300],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              agent.phone!,
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (agent.notes != null && agent.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes_outlined,
                          size: 18,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      agent.notes!,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentsProvider>(
      builder: (context, provider, child) {
        return AppLayout(
          currentPage: '/agents',
          title: 'Agents',
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Manage Your Agents',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ui.Button(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                                context, '/new-agent');
                            if (result == true) {
                              provider.loadAgents();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 20, color: Colors.grey[100]),
                              const SizedBox(width: 8),
                              Text(
                                'Add Agent',
                                style: TextStyle(
                                  color: Colors.grey[100],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ui.Input(
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        hintText: 'Search agents...',
                        controller: _searchController,
                        onChanged: (value) => provider.setSearchTerm(value),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.error != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    provider.error!,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ui.Button(
                                    onPressed: provider.loadAgents,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          size: 20,
                                          color: Colors.grey[100],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Try Again',
                                          style: TextStyle(
                                            color: Colors.grey[100],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : provider.filteredAgents.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No agents found',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[200],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your search or add a new agent',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(24),
                                  itemCount: provider.filteredAgents.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) =>
                                      _buildAgentCard(
                                          provider.filteredAgents[index]),
                                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
