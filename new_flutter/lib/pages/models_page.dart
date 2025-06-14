import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/model.dart';
import 'package:new_flutter/services/models_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  List<Model> _models = [];
  List<Model> _filteredModels = [];
  bool _isLoading = true;
  String? _error;
  bool _isGridView = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadModels() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final models = await ModelsService.list();

      if (mounted) {
        setState(() {
          _models = models;
          _filteredModels = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredModels = _models;
      } else {
        _filteredModels = _models.where((model) =>
          model.name.toLowerCase().contains(query.toLowerCase()) ||
          (model.agency?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (model.location?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/models',
      title: 'Models',
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/new-model');
            if (result == true) {
              _loadModels();
            }
          },
        ),
      ],
      child: _isLoading ? _buildLoadingWidget() : _buildContent(),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadModels,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredModels.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView()
                  : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search models...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No models found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/new-model');
              if (result == true) {
                _loadModels();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Model'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredModels.length,
      itemBuilder: (context, index) {
        final model = _filteredModels[index];
        return _buildModelCard(model);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredModels.length,
      itemBuilder: (context, index) {
        final model = _filteredModels[index];
        return _buildModelListItem(model);
      },
    );
  }

  Widget _buildModelCard(Model model) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showModelDetails(model),
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
                      model.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editModel(model);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(model);
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
              if (model.agency != null)
                Text(
                  model.agency!,
                  style: const TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 8),
              if (model.location != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        model.location!,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              if (model.height != null || model.measurements != null)
                Text(
                  '${model.height ?? ''} ${model.measurements ?? ''}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelListItem(Model model) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(model.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (model.agency != null) Text(model.agency!),
            if (model.location != null) Text(model.location!),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editModel(model);
            } else if (value == 'delete') {
              _showDeleteConfirmation(model);
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
        onTap: () => _showModelDetails(model),
      ),
    );
  }

  void _showModelDetails(Model model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(model.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (model.email != null) ...[
                  Text('Email: ${model.email}'),
                  const SizedBox(height: 8),
                ],
                if (model.phone != null) ...[
                  Text('Phone: ${model.phone}'),
                  const SizedBox(height: 8),
                ],
                if (model.agency != null) ...[
                  Text('Agency: ${model.agency}'),
                  const SizedBox(height: 8),
                ],
                if (model.location != null) ...[
                  Text('Location: ${model.location}'),
                  const SizedBox(height: 8),
                ],
                if (model.height != null) ...[
                  Text('Height: ${model.height}'),
                  const SizedBox(height: 8),
                ],
                if (model.measurements != null) ...[
                  Text('Measurements: ${model.measurements}'),
                  const SizedBox(height: 8),
                ],
                if (model.experience != null) ...[
                  Text('Experience: ${model.experience}'),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editModel(model);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _editModel(Model model) async {
    final result = await Navigator.pushNamed(
      context,
      '/new-model',
      arguments: model,
    );
    if (result == true && mounted) {
      _loadModels();
    }
  }

  void _showDeleteConfirmation(Model model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Model'),
          content: Text('Are you sure you want to delete "${model.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteModel(model);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteModel(Model model) async {
    if (model.id == null) return;

    try {
      final success = await ModelsService.delete(model.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Model deleted successfully'
                : 'Failed to delete model'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _loadModels();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting model: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
