import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:new_flutter/services/job_gallery_service.dart';
import 'package:new_flutter/models/job_gallery.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/theme/app_theme.dart';

class JobGalleryPage extends StatefulWidget {
  const JobGalleryPage({super.key});

  @override
  State<JobGalleryPage> createState() => _JobGalleryPageState();
}

class _JobGalleryPageState extends State<JobGalleryPage> {
  List<JobGallery> galleries = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGalleries();
  }

  Future<void> _loadGalleries() async {
    try {
      final loadedGalleries = await JobGalleryService.list();
      if (mounted) {
        setState(() {
          galleries = loadedGalleries;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading galleries: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<JobGallery> get filteredGalleries {
    if (searchQuery.isEmpty) return galleries;
    return galleries
        .where((gallery) =>
            gallery.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (gallery.description
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (gallery.photographerName
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/job-gallery',
      title: 'Job Gallery',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: AppTheme.goldColor),
          onPressed: () => Navigator.pushNamed(context, '/new-job-gallery'),
        ),
      ],
      child: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search galleries...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms),

          // Gallery Grid
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.goldColor),
                  )
                : filteredGalleries.isEmpty
                    ? _buildEmptyState()
                    : _buildGalleryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? 'No galleries yet' : 'No galleries found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Create your first gallery to showcase your work'
                : 'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/new-job-gallery'),
              icon: const Icon(Icons.add),
              label: const Text('Create Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldColor,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildGalleryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 400) crossAxisCount = 2;
        if (constraints.maxWidth > 700) crossAxisCount = 3;
        if (constraints.maxWidth > 1000) crossAxisCount = 4;
        if (constraints.maxWidth > 1300) crossAxisCount = 5;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredGalleries.length,
          itemBuilder: (context, index) {
            final gallery = filteredGalleries[index];
            return _buildGalleryCard(gallery, index);
          },
        );
      },
    );
  }

  Widget _buildGalleryCard(JobGallery gallery, int index) {
    // Parse images from JSON string if available
    List<String> imageUrls = [];
    if (gallery.images != null && gallery.images!.isNotEmpty) {
      try {
        // Handle both string and list formats
        if (gallery.images is String) {
          // Parse JSON string
          final dynamic parsed = gallery.images;
          if (parsed is String && parsed.startsWith('[')) {
            // It's a JSON array string, but for now just extract first URL
            final RegExp urlRegex = RegExp(r'"url":"([^"]+)"');
            final match = urlRegex.firstMatch(parsed);
            if (match != null) {
              imageUrls.add(match.group(1)!);
            }
          }
        } else if (gallery.images is List) {
          imageUrls = List<String>.from(gallery.images as List);
        }
      } catch (e) {
        // Silently handle parsing errors for frontend demo
        imageUrls = [];
      }
    }

    return GestureDetector(
      onTap: () => _showGalleryDetails(gallery),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.grey[800],
                ),
                child: imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: imageUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.goldColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.photo_library_outlined,
                        color: Colors.grey[600],
                        size: 32,
                      ),
              ),
            ),

            // Gallery Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gallery.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (gallery.photographerName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'by ${gallery.photographerName}',
                        style: const TextStyle(
                          color: AppTheme.goldColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (gallery.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[400],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              gallery.location!,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (imageUrls.isNotEmpty)
                          Text(
                            '${imageUrls.length} photo${imageUrls.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[500],
                          size: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editGallery(gallery);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(gallery);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
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
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  void _showGalleryDetails(JobGallery gallery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(gallery.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (gallery.photographerName != null) ...[
                  Text('Photographer: ${gallery.photographerName}'),
                  const SizedBox(height: 8),
                ],
                if (gallery.location != null) ...[
                  Text('Location: ${gallery.location}'),
                  const SizedBox(height: 8),
                ],
                if (gallery.description != null) ...[
                  Text('Description: ${gallery.description}'),
                  const SizedBox(height: 8),
                ],
                if (gallery.date != null) ...[
                  Text('Date: ${gallery.date}'),
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
                _editGallery(gallery);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _editGallery(JobGallery gallery) async {
    final result = await Navigator.pushNamed(
      context,
      '/new-job-gallery',
      arguments: gallery,
    );
    if (result == true && mounted) {
      _loadGalleries();
    }
  }

  void _showDeleteConfirmation(JobGallery gallery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Gallery'),
          content: Text('Are you sure you want to delete "${gallery.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteGallery(gallery);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGallery(JobGallery gallery) async {
    if (gallery.id == null) return;

    try {
      final success = await JobGalleryService.delete(gallery.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Gallery deleted successfully'
                : 'Failed to delete gallery'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          _loadGalleries();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting gallery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
