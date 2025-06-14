import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/button.dart' as ui;
import 'package:new_flutter/widgets/ui/input.dart' as ui;
import 'package:new_flutter/widgets/ui/card.dart' as ui;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/industry_contact.dart';
import '../providers/industry_contacts_provider.dart';

class IndustryContactsPage extends StatefulWidget {
  const IndustryContactsPage({super.key});

  @override
  State<IndustryContactsPage> createState() => _IndustryContactsPageState();
}

class _IndustryContactsPageState extends State<IndustryContactsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load contacts when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IndustryContactsProvider>().loadContacts();
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

  Future<void> _showDeleteConfirmation(IndustryContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Contact',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${contact.name}"? This action cannot be undone.',
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
      await _deleteContact(contact);
    }
  }

  Future<void> _deleteContact(IndustryContact contact) async {
    // Check if contact has a valid ID
    if (!contact.hasValidId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error: Contact ID is missing. Cannot delete contact.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // Show loading state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting contact...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final provider = context.read<IndustryContactsProvider>();
      final success = await provider.deleteContact(contact.id!);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ??
                  'Failed to delete contact. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildContactCard(IndustryContact contact) {
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
                        contact.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (contact.company != null ||
                          contact.jobTitle != null) ...[
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
                              [
                                contact.jobTitle,
                                contact.company,
                              ].where((e) => e != null).join(' at '),
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
                          '/new-industry-contact',
                          arguments: contact.id,
                        );
                        // Refresh the list if contact was edited
                        if (result == true && mounted) {
                          context
                              .read<IndustryContactsProvider>()
                              .loadContacts();
                        }
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: contact.hasValidId
                          ? () {
                              _showDeleteConfirmation(contact);
                            }
                          : null,
                      tooltip: contact.hasValidId
                          ? 'Delete'
                          : 'Cannot delete - Invalid ID',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (contact.email != null || contact.mobile != null) ...[
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
                    if (contact.email != null) ...[
                      InkWell(
                        onTap: () => _launchUrl('mailto:${contact.email}'),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mail_outline,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              contact.email!,
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (contact.mobile != null) ...[
                      if (contact.email != null) const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl('tel:${contact.mobile}'),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              contact.mobile!,
                              style: TextStyle(
                                color: Colors.blue[600],
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
            if (contact.notes != null && contact.notes!.isNotEmpty) ...[
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
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      contact.notes!,
                      style: TextStyle(
                        color: Colors.grey[700],
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
    return Consumer<IndustryContactsProvider>(
      builder: (context, provider, child) {
        final filteredContacts = provider.filteredContacts;

        return AppLayout(
          currentPage: '/industry-contacts',
          title: 'Industry Contacts',
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
                            'Manage Your Industry Contacts',
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
                                context, '/new-industry-contact');
                            // Refresh the list if contact was added
                            if (result == true && mounted) {
                              provider.loadContacts();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 20, color: Colors.grey[100]),
                              const SizedBox(width: 8),
                              Text(
                                'Add Contact',
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
                        hintText: 'Search contacts...',
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
                                    onPressed: provider.loadContacts,
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
                          : filteredContacts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.contacts_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No contacts found',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your search or add a new contact',
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
                                  itemCount: filteredContacts.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) =>
                                      _buildContactCard(
                                          filteredContacts[index]),
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
