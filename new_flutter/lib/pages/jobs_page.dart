import 'package:flutter/material.dart';
import 'package:new_flutter/models/job.dart';
import 'package:new_flutter/services/jobs_service.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/table.dart' as ui;
import 'package:new_flutter/widgets/ui/badge.dart' as ui;
import 'package:new_flutter/widgets/export_button.dart';
import 'package:intl/intl.dart';

const jobTypes = [
  'Add manually',
  'Advertisement',
  'Campaign',
  'Catalog',
  'Commercial',
  'Editorial',
  'Fashion Show',
  'Lookbook',
  'Print',
  'Runway',
  'Social Media',
  'TV Show',
  'Web Content',
  'Other',
];

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  List<Job> jobs = [];
  bool isLoading = true;
  String? error;
  String _viewMode = 'grid';
  String _sortOrder = 'date-desc';
  String _selectedStatus = 'all';
  final _searchController = TextEditingController();
  final Map<String, bool> _columnVisibility = {
    'date': true,
    'client_name': true,
    'type': true,
    'booking_agent': true,
    'rate': true,
    'extra_hours': true,
    'agency_fee': true,
    'tax': true,
    'finalAmount': true,
    'payment_status': true,
    'actions': true,
  };

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
      debugPrint('🔄 Loading jobs...');
      if (mounted) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      final loadedJobs = await JobsService.getJobs();
      debugPrint('✅ Loaded ${loadedJobs.length} jobs');

      if (mounted) {
        setState(() {
          jobs = loadedJobs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading jobs: $e');
      if (mounted) {
        setState(() {
          error = 'Failed to load jobs: $e';
          isLoading = false;
        });
      }
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
        final success = await JobsService.deleteJob(job.id!);
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

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Filter Jobs',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter by Status:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['all', 'pending', 'confirmed', 'completed', 'canceled']
                  .map((status) => FilterChip(
                        label: Text(status.toUpperCase()),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : 'all';
                          });
                          Navigator.pop(context);
                          _loadJobs();
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFFDCFCE7); // green-100
      case 'partially_paid':
        return const Color(0xFFFEF9C3); // yellow-100
      case 'unpaid':
        return const Color(0xFFFEE2E2); // red-100
      default:
        return const Color(0xFFF3F4F6); // gray-100
    }
  }

  Color _getPaymentStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF166534); // green-800
      case 'partially_paid':
        return const Color(0xFF854D0E); // yellow-800
      case 'unpaid':
        return const Color(0xFF991B1B); // red-800
      default:
        return const Color(0xFF1F2937); // gray-800
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: job.status == 'confirmed'
                        ? Colors.green[100]
                        : job.status == 'pending'
                            ? Colors.orange[100]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (job.status ?? 'pending').toUpperCase(),
                    style: TextStyle(
                      color: job.status == 'confirmed'
                          ? Colors.green[800]
                          : job.status == 'pending'
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
            LayoutBuilder(
              builder: (context, constraints) {
                // On very small cards, stack items vertically
                if (constraints.maxWidth < 250) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(job.date),
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (job.time != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                job.formatTime() ?? 'No time set',
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${job.currency} ${job.rate.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // On larger cards, use wrap layout
                return Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(job.date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (job.time != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            job.formatTime() ?? 'No time set',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_money,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${job.currency} ${job.rate.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
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
            if (job.requirements != null) ...[
              const SizedBox(height: 16),
              Text(
                'Requirements',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                job.requirements!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (job.images != null && job.images!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Images', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: job.images!.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        job.images![index],
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
            LayoutBuilder(
              builder: (context, constraints) {
                // On small cards, stack payment status and buttons vertically
                if (constraints.maxWidth < 300) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: job.paymentStatus == 'paid'
                              ? Colors.green[100]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (job.paymentStatus ?? 'unpaid').toUpperCase(),
                          style: TextStyle(
                            color: job.paymentStatus == 'paid'
                                ? Colors.green[800]
                                : Colors.grey[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                  _loadJobs();
                                }
                              },
                              text: 'Edit',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Button(
                              variant: ButtonVariant.destructive,
                              onPressed: () =>
                                  _showDeleteConfirmation(context, job),
                              text: 'Delete',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // On larger cards, use horizontal layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: job.paymentStatus == 'paid'
                            ? Colors.green[100]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (job.paymentStatus ?? 'unpaid').toUpperCase(),
                        style: TextStyle(
                          color: job.paymentStatus == 'paid'
                              ? Colors.green[800]
                              : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Button(
                          variant: ButtonVariant.outline,
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/new-job',
                              arguments: job,
                            );
                            if (result == true) {
                              _loadJobs();
                            }
                          },
                          text: 'Edit',
                        ),
                        const SizedBox(width: 8),
                        Button(
                          variant: ButtonVariant.destructive,
                          onPressed: () =>
                              _showDeleteConfirmation(context, job),
                          text: 'Delete',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsTable() {
    return ui.Table(
      children: [
        ui.TableHead(
          children: [
            if (_columnVisibility['date']!)
              ui.TableHeader(
                child: Row(
                  children: [
                    const Text('Date'),
                    IconButton(
                      icon: Icon(
                        _sortOrder == 'date-asc'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortOrder = _sortOrder == 'date-asc'
                              ? 'date-desc'
                              : 'date-asc';
                        });
                      },
                    ),
                  ],
                ),
              ),
            if (_columnVisibility['client_name']!)
              const ui.TableHeader(child: Text('Client')),
            if (_columnVisibility['type']!)
              const ui.TableHeader(child: Text('Type')),
            if (_columnVisibility['booking_agent']!)
              const ui.TableHeader(child: Text('Booking Agent')),
            if (_columnVisibility['rate']!)
              const ui.TableHeader(child: Text('Rate')),
            if (_columnVisibility['extra_hours']!)
              const ui.TableHeader(child: Text('Extra Hours')),
            if (_columnVisibility['agency_fee']!)
              const ui.TableHeader(child: Text('Agency Fee')),
            if (_columnVisibility['tax']!)
              const ui.TableHeader(child: Text('Tax')),
            if (_columnVisibility['finalAmount']!)
              const ui.TableHeader(child: Text('Final Amount')),
            if (_columnVisibility['payment_status']!)
              const ui.TableHeader(child: Text('Payment Status')),
            if (_columnVisibility['actions']!)
              const ui.TableHeader(child: Text('Actions')),
          ],
        ),
        ui.TableBody(
          children: jobs.map((job) {
            return ui.TableRow(
              children: [
                if (_columnVisibility['date']!)
                  ui.TableCell(
                    child: Text(_formatDate(job.date)),
                  ),
                if (_columnVisibility['client_name']!)
                  ui.TableCell(child: Text(job.clientName)),
                if (_columnVisibility['type']!)
                  ui.TableCell(child: Text(job.type)),
                if (_columnVisibility['booking_agent']!)
                  ui.TableCell(
                    child: Text(job.bookingAgent ?? 'N/A'),
                  ),
                if (_columnVisibility['rate']!)
                  ui.TableCell(
                    child: Text(
                      NumberFormat.currency(
                        symbol: job.currency,
                        decimalDigits: 2,
                      ).format(job.rate),
                    ),
                  ),
                if (_columnVisibility['extra_hours']!)
                  ui.TableCell(
                    child: Text(
                      NumberFormat.currency(
                        symbol: job.currency,
                        decimalDigits: 2,
                      ).format(job.extraHours ?? 0),
                    ),
                  ),
                if (_columnVisibility['agency_fee']!)
                  ui.TableCell(
                    child: Text('${job.agencyFeePercentage ?? 0}%'),
                  ),
                if (_columnVisibility['tax']!)
                  ui.TableCell(child: Text('${job.taxPercentage ?? 0}%')),
                if (_columnVisibility['finalAmount']!)
                  ui.TableCell(
                    child: Text(
                      NumberFormat.currency(
                        symbol: job.currency,
                        decimalDigits: 2,
                      ).format(job.calculateTotal()),
                    ),
                  ),
                if (_columnVisibility['payment_status']!)
                  ui.TableCell(
                    child: ui.Badge(
                      label: job.paymentStatus ?? 'unpaid',
                      backgroundColor: _getPaymentStatusColor(
                        job.paymentStatus ?? 'unpaid',
                      ),
                      textColor: _getPaymentStatusTextColor(
                        job.paymentStatus ?? 'unpaid',
                      ),
                      variant: ui.BadgeVariant.outline,
                    ),
                  ),
                if (_columnVisibility['actions']!)
                  ui.TableCell(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/new-job',
                              arguments: job,
                            );
                            if (result == true) {
                              _loadJobs();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _showDeleteConfirmation(context, job),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/jobs',
      title: 'Jobs',
      actions: [
        // Export button
        ExportButton(
          type: ExportType.jobs,
          data: jobs,
          customFilename: 'jobs_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadJobs,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/new-job'),
          tooltip: 'Add Job',
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // On small screens, stack search and controls vertically
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      ui.Input(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search jobs...',
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Button(
                              text: 'Filter',
                              variant: ButtonVariant.outline,
                              prefix: const Icon(Icons.filter_list),
                              onPressed: () => _showFilterDialog(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _viewMode == 'grid'
                                    ? Icons.view_list
                                    : Icons.grid_view,
                              ),
                              onPressed: () {
                                setState(() {
                                  _viewMode =
                                      _viewMode == 'grid' ? 'list' : 'grid';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // On larger screens, use horizontal layout
                return Row(
                  children: [
                    Expanded(
                      child: ui.Input(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search jobs...',
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Button(
                      text: 'Filter',
                      variant: ButtonVariant.outline,
                      prefix: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _viewMode == 'grid' ? Icons.view_list : Icons.grid_view,
                      ),
                      onPressed: () {
                        setState(() {
                          _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading jobs...'),
                  ],
                ),
              ),
            )
          else if (error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error loading jobs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Button(
                      text: 'Retry',
                      onPressed: _loadJobs,
                    ),
                  ],
                ),
              ),
            )
          else if (jobs.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No jobs found',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your first job to get started',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Button(
                      text: 'Add Job',
                      onPressed: () => Navigator.pushNamed(context, '/new-job'),
                    ),
                  ],
                ),
              ),
            )
          else if (_viewMode == 'grid')
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 3;
                  double childAspectRatio = 1.2;

                  if (constraints.maxWidth < 1200) {
                    crossAxisCount = 2;
                    childAspectRatio = 1.1;
                  }
                  if (constraints.maxWidth < 800) {
                    crossAxisCount = 1;
                    childAspectRatio = 1.3;
                  }

                  return GridView.builder(
                    padding:
                        EdgeInsets.all(constraints.maxWidth < 600 ? 8 : 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: constraints.maxWidth < 600 ? 8 : 16,
                      mainAxisSpacing: constraints.maxWidth < 600 ? 8 : 16,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) => _buildJobCard(jobs[index]),
                  );
                },
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // On small screens, show cards instead of table
                  if (constraints.maxWidth < 800) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) =>
                          _buildJobCard(jobs[index]),
                    );
                  }

                  // On larger screens, show table with horizontal scroll
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(0),
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - 32,
                      ),
                      child: _buildJobsTable(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
