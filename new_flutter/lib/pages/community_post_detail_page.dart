import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/theme/app_theme.dart';
import 'package:new_flutter/widgets/ui/button.dart';
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/models/community_post.dart';
import 'package:new_flutter/services/community_service.dart';

class CommunityPostDetailPage extends StatefulWidget {
  final CommunityPost post;

  const CommunityPostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<CommunityPostDetailPage> createState() => _CommunityPostDetailPageState();
}

class _CommunityPostDetailPageState extends State<CommunityPostDetailPage> {
  final _commentController = TextEditingController();
  final List<Comment> _comments = [];
  bool _isLoading = false;
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // Comment editing state
  String? _editingCommentId;
  final Map<String, TextEditingController> _commentEditControllers = {};

  @override
  void initState() {
    super.initState();
    // Parse title and description from content
    final lines = widget.post.content.split('\n');
    final title = lines.isNotEmpty ? lines[0] : 'Untitled';
    final description = lines.length > 1 ? lines.skip(1).join('\n').trim() : '';

    _titleController = TextEditingController(text: title);
    _descriptionController = TextEditingController(text: description);
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    // Dispose all comment edit controllers
    for (final controller in _commentEditControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadComments() async {
    debugPrint('🔄 Loading comments for post: ${widget.post.id}');
    setState(() {
      _isLoading = true;
    });

    try {
      final comments = await CommunityService.getComments(widget.post.id);
      debugPrint('📥 Loaded ${comments.length} comments');
      if (mounted) {
        setState(() {
          _comments.clear();
          _comments.addAll(comments);
          _isLoading = false;
        });
        debugPrint('🎯 UI updated with ${_comments.length} comments');
      }
    } catch (e) {
      debugPrint('❌ Error loading comments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading comments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await CommunityService.addComment(widget.post.id, _commentController.text.trim());
      _commentController.clear();

      // Reload comments to get the updated list
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveEdit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newContent = '${_titleController.text}\n\n${_descriptionController.text}';
      await CommunityService.updatePost(
        widget.post.id,
        newContent,
        category: widget.post.category,
        location: widget.post.location,
        date: widget.post.date,
        time: widget.post.time,
        contactMethod: widget.post.contactMethod,
      );

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to refresh the post list
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error updating post: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Post', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: Colors.white),
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

    if (confirmed == true) {
      try {
        await CommunityService.deletePost(widget.post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint('Error deleting post: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting post: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete Comment', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this comment?',
          style: TextStyle(color: Colors.white),
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

    if (confirmed == true) {
      try {
        await CommunityService.deleteComment(comment.id, widget.post.id);
        await _loadComments(); // Reload comments
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error deleting comment: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting comment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _startEditingComment(Comment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _commentEditControllers[comment.id] = TextEditingController(text: comment.content);
    });
  }

  void _cancelEditingComment() {
    setState(() {
      if (_editingCommentId != null) {
        _commentEditControllers[_editingCommentId!]?.dispose();
        _commentEditControllers.remove(_editingCommentId!);
        _editingCommentId = null;
      }
    });
  }

  Future<void> _saveEditComment(Comment comment) async {
    final controller = _commentEditControllers[comment.id];
    if (controller == null || controller.text.trim().isEmpty) return;

    try {
      await CommunityService.updateComment(comment.id, controller.text.trim());

      // Reload comments to get the updated list
      await _loadComments();

      // Clear editing state
      _cancelEditingComment();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPostContent() {
    if (_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ui.Input(
            label: 'Title',
            controller: _titleController,
          ),
          const SizedBox(height: 16),
          ui.Input(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Button(
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Reset to original content
                      final lines = widget.post.content.split('\n');
                      final title = lines.isNotEmpty ? lines[0] : 'Untitled';
                      final description = lines.length > 1 ? lines.skip(1).join('\n').trim() : '';
                      _titleController.text = title;
                      _descriptionController.text = description;
                    });
                  },
                  text: 'Cancel',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Button(
                  onPressed: _isLoading ? null : _saveEdit,
                  text: _isLoading ? 'Saving...' : 'Save',
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.post.content.split('\n').isNotEmpty
                    ? widget.post.content.split('\n')[0]
                    : 'Untitled',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (CommunityService.canEditPost(widget.post)) ...[
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.goldColor),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                tooltip: 'Edit Post',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deletePost,
                tooltip: 'Delete Post',
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.goldColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.post.category ?? 'General',
            style: const TextStyle(
              color: AppTheme.goldColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.post.content.split('\n').length > 1
              ? widget.post.content.split('\n').skip(1).join('\n').trim()
              : widget.post.content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              widget.post.authorName,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(width: 16),
            Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              _formatTimestamp(widget.post.timestamp),
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
        if (widget.post.location != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                widget.post.location!,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ],
        if (widget.post.date != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                widget.post.date!,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.goldColor),
              onPressed: _loadComments,
              tooltip: 'Refresh Comments',
            ),
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.orange),
              onPressed: () async {
                await CommunityService.debugAllComments();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debug info printed to console'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              tooltip: 'Debug Comments',
            ),
            IconButton(
              icon: const Icon(Icons.science, color: Colors.green),
              onPressed: () async {
                final result = await CommunityService.testCommentFunctionality(widget.post.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result),
                      backgroundColor: result.contains('passed') ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                  // Refresh comments after test
                  _loadComments();
                }
              },
              tooltip: 'Test Comments',
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Add comment form
        Row(
          children: [
            Expanded(
              child: ui.Input(
                controller: _commentController,
                placeholder: 'Write a comment...',
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 16),
            Button(
              onPressed: _isLoading ? null : _addComment,
              text: 'Post Comment',
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Comments list
        if (_isLoading && _comments.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          const Center(
            child: Text(
              'No comments yet. Be the first to comment!',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final comment = _comments[index];
              final isEditing = _editingCommentId == comment.id;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.goldColor,
                          ),
                        ),
                        const Spacer(),
                        if (CommunityService.canEditComment(comment)) ...[
                          if (!isEditing) ...[
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16, color: AppTheme.goldColor),
                              onPressed: () => _startEditingComment(comment),
                              tooltip: 'Edit Comment',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                          ],
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            onPressed: () => _deleteComment(comment),
                            tooltip: 'Delete Comment',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTimestamp(comment.timestamp),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            if (comment.updatedAt != null)
                              Text(
                                'edited',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isEditing) ...[
                      // Edit mode
                      ui.Input(
                        controller: _commentEditControllers[comment.id]!,
                        placeholder: 'Edit your comment...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _cancelEditingComment,
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          Button(
                            onPressed: () => _saveEditComment(comment),
                            text: 'Save',
                          ),
                        ],
                      ),
                    ] else ...[
                      // Display mode
                      Text(
                        comment.content,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/community-board',
      title: 'Post Details',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostContent(),
            const SizedBox(height: 32),
            const Divider(color: Colors.grey),
            const SizedBox(height: 32),
            _buildCommentSection(),
          ],
        ),
      ),
    );
  }
}


