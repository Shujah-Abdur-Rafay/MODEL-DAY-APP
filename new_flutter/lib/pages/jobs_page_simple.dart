import 'package:flutter/material.dart';
import 'package:new_flutter/models/job.dart';
import 'package:new_flutter/services/jobs_service.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';

class JobsPageSimple extends StatefulWidget {
  const JobsPageSimple({super.key});

  @override
  State<JobsPageSimple> createState() => _JobsPageSimpleState();
}

class _JobsPageSimpleState extends State<JobsPageSimple> {
  List<Job> jobs = [];
  bool isLoading = true;
  String? error;
  String _searchTerm = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedJobs = await JobsService.list();
      setState(() {
        jobs = loadedJobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load jobs: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Job job) async {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Job',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the job for "${job.clientName}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      try {
        final success = await JobsService.delete(job.id!);
        if (success) {
          await _loadJobs();
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Job deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Failed to delete job');
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Error deleting job: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  List<Job> get _filteredJobs {
    if (_searchTerm.isEmpty) return jobs;
    final term = _searchTerm.toLowerCase();
    return jobs.where((job) {
      return job.clientName.toLowerCase().contains(term) ||
          job.type.toLowerCase().contains(term) ||
          job.location.toLowerCase().contains(term);
    }).toList();
  }

  Widget _buildJobCard(Job job) {
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
                        job.clientName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.type,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
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
                  job.date,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (job.time != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    job.time!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${job.currency ?? 'USD'} ${job.rate.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (job.notes != null) ...[
              const SizedBox(height: 16),
              Text('Notes', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                job.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Button(
                    variant: ButtonVariant.outline,
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/new-job',
                        arguments: job,
                      );
                      if (result == true) {
                        _loadJobs(); // Refresh the jobs list
                      }
                    },
                    text: 'Edit',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Button(
                    variant: ButtonVariant.destructive,
                    onPressed: () => _showDeleteConfirmation(context, job),
                    text: 'Delete',
                  ),
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
    return AppLayout(
      currentPage: 'Jobs',
      title: 'Jobs',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/new-job');
            if (result == true) {
              _loadJobs(); // Refresh the jobs list
            }
          },
          tooltip: 'Add Job',
        ),
      ],
      child: Column(
        children: [
          // Search and controls
          Row(
            children: [
              Expanded(
                child: ui.Input(
                  placeholder: 'Search jobs...',
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Button(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/new-job');
                  if (result == true) {
                    _loadJobs(); // Refresh the jobs list
                  }
                },
                text: 'Add Job',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            Button(
                              onPressed: _loadJobs,
                              text: 'Retry',
                            ),
                          ],
                        ),
                      )
                    : _filteredJobs.isEmpty
                        ? const Center(
                            child: Text('No jobs found'),
                          )
                        : ListView.builder(
                            itemCount: _filteredJobs.length,
                            itemBuilder: (context, index) {
                              return _buildJobCard(_filteredJobs[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
