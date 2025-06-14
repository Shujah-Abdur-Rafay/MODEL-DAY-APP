import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/shooting.dart';
import 'package:new_flutter/services/shootings_service.dart';

class ShootingsPage extends StatefulWidget {
  const ShootingsPage({super.key});

  @override
  State<ShootingsPage> createState() => _ShootingsPageState();
}

class _ShootingsPageState extends State<ShootingsPage> {
  List<Shooting> _shootings = [];
  List<Shooting> _filteredShootings = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShootings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShootings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final shootings = await ShootingsService.list();
      if (!mounted) return;
      setState(() {
        _shootings = shootings;
        _filteredShootings = shootings;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shootings: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filteredShootings = _shootings.where((shooting) {
        final searchLower = _searchQuery.toLowerCase();
        return shooting.clientName.toLowerCase().contains(searchLower) ||
            (shooting.type?.toLowerCase().contains(searchLower) ?? false) ||
            (shooting.location?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      _filteredShootings.sort((a, b) {
        try {
          final dateA = DateTime.tryParse(a.date) ?? DateTime(1900);
          final dateB = DateTime.tryParse(b.date) ?? DateTime(1900);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
    });
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search shootings...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _filteredShootings.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView()
                  : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No shootings found',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/new-shooting'),
            icon: const Icon(Icons.add),
            label: const Text('Add New Shooting'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 600) crossAxisCount = 2;
        if (constraints.maxWidth > 900) crossAxisCount = 3;
        if (constraints.maxWidth > 1200) crossAxisCount = 4;

        return GridView.builder(
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredShootings.length,
          itemBuilder: (context, index) =>
              _buildShootingCard(_filteredShootings[index]),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredShootings.length,
      itemBuilder: (context, index) =>
          _buildShootingListItem(_filteredShootings[index]),
    );
  }

  Widget _buildShootingCard(Shooting shooting) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shooting.clientName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(shooting.status),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editShooting(shooting);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(shooting);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(shooting.type ?? 'No Type',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_formatDate(shooting.date),
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            if (shooting.rate != null)
              Text('\$${shooting.rate!.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildShootingListItem(Shooting shooting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(shooting.clientName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shooting.type ?? 'No Type'),
            Text(_formatDate(shooting.date)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (shooting.rate != null)
              Text('\$${shooting.rate!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            _buildStatusChip(shooting.status),
          ],
        ),
        onTap: () => Navigator.pushNamed(context, '/new-shooting',
            arguments: shooting.id),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status?.toUpperCase() ?? 'UNKNOWN',
          style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _editShooting(Shooting shooting) async {
    final result = await Navigator.pushNamed(
      context,
      '/new-shooting',
      arguments: shooting,
    );
    if (result == true && mounted) {
      _loadShootings();
    }
  }

  void _showDeleteConfirmation(Shooting shooting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Shooting'),
          content: Text('Are you sure you want to delete "${shooting.clientName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteShooting(shooting);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteShooting(Shooting shooting) async {
    try {
      final success = await ShootingsService.delete(shooting.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Shooting deleted successfully'
                : 'Failed to delete shooting'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _loadShootings();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting shooting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/shootings',
      title: 'Shootings',
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            if (mounted) setState(() => _isGridView = !_isGridView);
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-shooting'),
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
}
