import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/export_button.dart';
import 'package:new_flutter/models/polaroid.dart';
import 'package:new_flutter/services/polaroids_service.dart';

class PolaroidsPage extends StatefulWidget {
  const PolaroidsPage({super.key});

  @override
  State<PolaroidsPage> createState() => _PolaroidsPageState();
}

class _PolaroidsPageState extends State<PolaroidsPage> {
  List<Polaroid> _polaroids = [];
  List<Polaroid> _filteredPolaroids = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPolaroids();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPolaroids() async {
    if (!mounted) return;
    debugPrint('📸 PolaroidsPage._loadPolaroids() - Starting to load polaroids');
    setState(() => _isLoading = true);
    try {
      final polaroids = await PolaroidsService.list();
      debugPrint('📸 PolaroidsPage._loadPolaroids() - Loaded ${polaroids.length} polaroids');

      for (var polaroid in polaroids) {
        debugPrint('📸 Polaroid: ${polaroid.clientName} (${polaroid.id})');
      }

      if (!mounted) return;
      setState(() {
        _polaroids = polaroids;
        _filteredPolaroids = polaroids;
        _isLoading = false;
      });
      _applyFilters();
      debugPrint('📸 PolaroidsPage._loadPolaroids() - Finished loading polaroids');
    } catch (e) {
      debugPrint('📸 Error loading polaroids: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading polaroids: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      _filteredPolaroids = _polaroids.where((polaroid) {
        final searchLower = _searchQuery.toLowerCase();
        return polaroid.clientName.toLowerCase().contains(searchLower) ||
            (polaroid.type?.toLowerCase().contains(searchLower) ?? false) ||
            (polaroid.location?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      _filteredPolaroids.sort((a, b) {
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
              hintText: 'Search polaroids...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _filteredPolaroids.isEmpty
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
          const Icon(Icons.photo_camera, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No polaroids found',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/new-polaroid'),
            icon: const Icon(Icons.add),
            label: const Text('Add New Polaroid'),
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
          itemCount: _filteredPolaroids.length,
          itemBuilder: (context, index) =>
              _buildPolaroidCard(_filteredPolaroids[index]),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _filteredPolaroids.length,
      itemBuilder: (context, index) =>
          _buildPolaroidListItem(_filteredPolaroids[index]),
    );
  }

  Widget _buildPolaroidCard(Polaroid polaroid) {
    // Create a meaningful title for the polaroid
    String title = 'Polaroid Session';
    if (polaroid.type != null && polaroid.type!.isNotEmpty) {
      title = '${polaroid.type} Polaroid';
    }
    if (polaroid.location != null && polaroid.location!.isNotEmpty) {
      title += ' - ${polaroid.location}';
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _editPolaroid(polaroid),
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
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(polaroid.status),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editPolaroid(polaroid);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(polaroid);
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
              if (polaroid.location != null && polaroid.location!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        polaroid.location!,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (polaroid.location != null && polaroid.location!.isNotEmpty)
                const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(_formatDate(polaroid.date),
                      style: const TextStyle(color: Colors.grey)),
                  if (polaroid.time != null && polaroid.time!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(polaroid.time!,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
              if (polaroid.notes != null && polaroid.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  polaroid.notes!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              if (polaroid.rate != null)
                Text('\$${polaroid.rate!.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolaroidListItem(Polaroid polaroid) {
    // Create a meaningful title for the polaroid
    String title = 'Polaroid Session';
    if (polaroid.type != null && polaroid.type!.isNotEmpty) {
      title = '${polaroid.type} Polaroid';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (polaroid.location != null && polaroid.location!.isNotEmpty)
              Text('📍 ${polaroid.location}'),
            Text('📅 ${_formatDate(polaroid.date)}'),
            if (polaroid.time != null && polaroid.time!.isNotEmpty)
              Text('🕐 ${polaroid.time}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (polaroid.rate != null)
              Text('\$${polaroid.rate!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            _buildStatusChip(polaroid.status),
          ],
        ),
        onTap: () async {
          debugPrint('📸 PolaroidsPage - List item tapped: $title (${polaroid.id})');
          final result = await Navigator.pushNamed(context, '/new-polaroid',
              arguments: polaroid.id);
          if (result == true && mounted) {
            _loadPolaroids();
          }
        },
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

  void _editPolaroid(Polaroid polaroid) async {
    debugPrint('📸 PolaroidsPage._editPolaroid() - Editing polaroid: ${polaroid.clientName} (${polaroid.id})');
    final result = await Navigator.pushNamed(
      context,
      '/new-polaroid',
      arguments: polaroid.id, // Pass the ID, not the object
    );
    if (result == true && mounted) {
      debugPrint('📸 PolaroidsPage._editPolaroid() - Edit completed, reloading polaroids');
      _loadPolaroids();
    }
  }

  void _showDeleteConfirmation(Polaroid polaroid) {
    // Create a meaningful title for the polaroid
    String title = 'Polaroid Session';
    if (polaroid.type != null && polaroid.type!.isNotEmpty) {
      title = '${polaroid.type} Polaroid';
    }
    if (polaroid.location != null && polaroid.location!.isNotEmpty) {
      title += ' at ${polaroid.location}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Polaroid'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePolaroid(polaroid);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePolaroid(Polaroid polaroid) async {
    try {
      final success = await PolaroidsService.delete(polaroid.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Polaroid deleted successfully'
                : 'Failed to delete polaroid'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _loadPolaroids();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting polaroid: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/polaroids',
      title: 'Polaroids',
      actions: [
        // Export button
        ExportButton(
          type: ExportType.polaroids,
          data: _filteredPolaroids,
          customFilename: 'polaroids_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            if (mounted) setState(() => _isGridView = !_isGridView);
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-polaroid'),
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
}
