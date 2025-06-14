import 'package:flutter/material.dart';
import 'package:new_flutter/services/export_service.dart';
import 'package:new_flutter/theme/app_theme.dart';

enum ExportType {
  events,
  jobs,
  agents,
  agencies,
  castings,
  tests,
  meetings,
  onStays,
  directBookings,
  polaroids,
}

class ExportButton extends StatefulWidget {
  final ExportType type;
  final List<dynamic> data;
  final String? customFilename;
  final VoidCallback? onExportStart;
  final VoidCallback? onExportComplete;
  final Function(String)? onError;

  const ExportButton({
    super.key,
    required this.type,
    required this.data,
    this.customFilename,
    this.onExportStart,
    this.onExportComplete,
    this.onError,
  });

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    if (_isExporting || widget.data.isEmpty) return;

    setState(() {
      _isExporting = true;
    });

    widget.onExportStart?.call();

    try {
      switch (widget.type) {
        case ExportType.events:
          await ExportService.exportEvents(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.jobs:
          await ExportService.exportJobs(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.agents:
          await ExportService.exportAgents(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.agencies:
          await ExportService.exportAgencies(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.castings:
          await ExportService.exportCastings(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.tests:
          await ExportService.exportTests(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.meetings:
          await ExportService.exportMeetings(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.onStays:
          await ExportService.exportOnStays(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.directBookings:
          await ExportService.exportDirectBookings(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.polaroids:
          await ExportService.exportPolaroids(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
      }

      widget.onExportComplete?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getTypeName()} exported successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      widget.onError?.call(e.toString());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _getTypeName() {
    switch (widget.type) {
      case ExportType.events:
        return 'Events';
      case ExportType.jobs:
        return 'Jobs';
      case ExportType.agents:
        return 'Agents';
      case ExportType.agencies:
        return 'Agencies';
      case ExportType.castings:
        return 'Castings';
      case ExportType.tests:
        return 'Tests';
      case ExportType.meetings:
        return 'Meetings';
      case ExportType.onStays:
        return 'On Stays';
      case ExportType.directBookings:
        return 'Direct Bookings';
      case ExportType.polaroids:
        return 'Polaroids';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.data.isEmpty;
    
    return Tooltip(
      message: isEmpty 
          ? 'No ${_getTypeName().toLowerCase()} to export'
          : 'Export ${_getTypeName().toLowerCase()} to CSV',
      child: ElevatedButton.icon(
        onPressed: isEmpty || _isExporting ? null : _handleExport,
        icon: _isExporting
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              )
            : Icon(
                Icons.download,
                size: 18,
                color: isEmpty ? Colors.grey : Colors.black,
              ),
        label: Text(
          _isExporting ? 'Exporting...' : 'Export',
          style: TextStyle(
            color: isEmpty ? Colors.grey : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEmpty ? Colors.grey[300] : AppTheme.goldColor,
          foregroundColor: isEmpty ? Colors.grey : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isEmpty ? 0 : 2,
        ),
      ),
    );
  }
}

// Floating Action Button variant for export
class ExportFab extends StatefulWidget {
  final ExportType type;
  final List<dynamic> data;
  final String? customFilename;
  final VoidCallback? onExportStart;
  final VoidCallback? onExportComplete;
  final Function(String)? onError;

  const ExportFab({
    super.key,
    required this.type,
    required this.data,
    this.customFilename,
    this.onExportStart,
    this.onExportComplete,
    this.onError,
  });

  @override
  State<ExportFab> createState() => _ExportFabState();
}

class _ExportFabState extends State<ExportFab> {
  bool _isExporting = false;

  Future<void> _handleExport() async {
    if (_isExporting || widget.data.isEmpty) return;

    setState(() {
      _isExporting = true;
    });

    widget.onExportStart?.call();

    try {
      switch (widget.type) {
        case ExportType.events:
          await ExportService.exportEvents(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.jobs:
          await ExportService.exportJobs(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.agents:
          await ExportService.exportAgents(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.agencies:
          await ExportService.exportAgencies(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.castings:
          await ExportService.exportCastings(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.tests:
          await ExportService.exportTests(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.meetings:
          await ExportService.exportMeetings(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.onStays:
          await ExportService.exportOnStays(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.directBookings:
          await ExportService.exportDirectBookings(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
        case ExportType.polaroids:
          await ExportService.exportPolaroids(
            widget.data.cast(),
            filename: widget.customFilename,
          );
          break;
      }

      widget.onExportComplete?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getTypeName()} exported successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      widget.onError?.call(e.toString());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  String _getTypeName() {
    switch (widget.type) {
      case ExportType.events:
        return 'Events';
      case ExportType.jobs:
        return 'Jobs';
      case ExportType.agents:
        return 'Agents';
      case ExportType.agencies:
        return 'Agencies';
      case ExportType.castings:
        return 'Castings';
      case ExportType.tests:
        return 'Tests';
      case ExportType.meetings:
        return 'Meetings';
      case ExportType.onStays:
        return 'On Stays';
      case ExportType.directBookings:
        return 'Direct Bookings';
      case ExportType.polaroids:
        return 'Polaroids';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.data.isEmpty;
    
    return FloatingActionButton.extended(
      onPressed: isEmpty || _isExporting ? null : _handleExport,
      icon: _isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : const Icon(Icons.download, color: Colors.black),
      label: Text(
        _isExporting ? 'Exporting...' : 'Export',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isEmpty ? Colors.grey[300] : AppTheme.goldColor,
      elevation: isEmpty ? 0 : 6,
    );
  }
}
