import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/casting.dart';
import '../providers/castings_provider.dart';
import '../widgets/app_layout.dart';
import '../widgets/ui/button.dart';
import '../widgets/ui/input.dart' as ui;
import '../widgets/export_button.dart';

class CastingsPage extends StatefulWidget {
  const CastingsPage({super.key});

  @override
  State<CastingsPage> createState() => _CastingsPageState();
}

class _CastingsPageState extends State<CastingsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CastingsProvider>().loadCastings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteCasting(String id) async {
    final provider = context.read<CastingsProvider>();
    final success = await provider.deleteCasting(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Casting deleted successfully'
              : provider.error ?? 'Error deleting casting'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Widget _buildCastingCard(Casting casting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        casting.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        casting.description ?? 'No description',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: casting.status == 'confirmed'
                        ? Colors.green[100]
                        : casting.status == 'pending'
                            ? Colors.orange[100]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    casting.status.toUpperCase(),
                    style: TextStyle(
                      color: casting.status == 'confirmed'
                          ? Colors.green[800]
                          : casting.status == 'pending'
                              ? Colors.orange[800]
                              : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, yyyy').format(casting.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (casting.rate != null) ...[
                  const SizedBox(width: 24),
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${casting.currency ?? 'USD'} ${casting.rate!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    casting.location ?? 'No location',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Requirements', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              casting.requirements ?? 'No requirements specified',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (casting.images != null && casting.images!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Images', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: casting.images!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        casting.images![index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/new-casting',
                      arguments: casting,
                    );
                    if (result == true && mounted) {
                      context.read<CastingsProvider>().loadCastings();
                    }
                  },
                  text: 'Edit',
                ),
                const SizedBox(width: 8),
                Button(
                  variant: ButtonVariant.destructive,
                  onPressed: () => _deleteCasting(casting.id),
                  text: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CastingsProvider>(
      builder: (context, provider, child) {
        return AppLayout(
          currentPage: '/castings',
          title: 'Castings',
          actions: [
            // Export button
            ExportButton(
              type: ExportType.castings,
              data: provider.filteredCastings,
              customFilename: 'castings_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(context, '/new-casting');
                if (result == true) {
                  provider.loadCastings();
                }
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ui.Input(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search castings...',
                  controller: _searchController,
                  onChanged: (value) => provider.setSearchTerm(value),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.error != null
                            ? Center(child: Text(provider.error!))
                            : provider.filteredCastings.isEmpty
                                ? const Center(child: Text('No castings found'))
                                : ListView.builder(
                                    itemCount: provider.filteredCastings.length,
                                    itemBuilder: (context, index) =>
                                        _buildCastingCard(
                                            provider.filteredCastings[index]),
                                  ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
