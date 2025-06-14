import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:new_flutter/models/event.dart';
import 'package:new_flutter/models/job.dart';
import 'package:new_flutter/models/agent.dart';
import 'package:new_flutter/models/agency.dart';
import 'package:new_flutter/models/casting.dart';
import 'package:new_flutter/models/test.dart';
import 'package:new_flutter/models/meeting.dart';
import 'package:new_flutter/models/on_stay.dart';
import 'package:new_flutter/models/direct_booking.dart';
import 'package:new_flutter/models/polaroid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  static const String _csvSeparator = ',';

  // Export events to CSV
  static Future<void> exportEvents(List<Event> events, {String? filename}) async {
    try {
      final csvData = _generateEventsCsv(events);
      final fileName = filename ?? 'events_${_getTimestamp()}.csv';
      
      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting events: $e');
      rethrow;
    }
  }

  // Export jobs to CSV
  static Future<void> exportJobs(List<Job> jobs, {String? filename}) async {
    try {
      final csvData = _generateJobsCsv(jobs);
      final fileName = filename ?? 'jobs_${_getTimestamp()}.csv';
      
      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting jobs: $e');
      rethrow;
    }
  }

  // Export agents to CSV
  static Future<void> exportAgents(List<Agent> agents, {String? filename}) async {
    try {
      final csvData = _generateAgentsCsv(agents);
      final fileName = filename ?? 'agents_${_getTimestamp()}.csv';
      
      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting agents: $e');
      rethrow;
    }
  }

  // Export agencies to CSV
  static Future<void> exportAgencies(List<Agency> agencies, {String? filename}) async {
    try {
      final csvData = _generateAgenciesCsv(agencies);
      final fileName = filename ?? 'agencies_${_getTimestamp()}.csv';

      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting agencies: $e');
      rethrow;
    }
  }

  // Export castings to CSV
  static Future<void> exportCastings(List<Casting> castings, {String? filename}) async {
    try {
      final csvData = _generateCastingsCsv(castings);
      final fileName = filename ?? 'castings_${_getTimestamp()}.csv';

      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting castings: $e');
      rethrow;
    }
  }

  // Export tests to CSV
  static Future<void> exportTests(List<Test> tests, {String? filename}) async {
    try {
      final csvData = _generateTestsCsv(tests);
      final fileName = filename ?? 'tests_${_getTimestamp()}.csv';

      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting tests: $e');
      rethrow;
    }
  }

  // Export meetings to CSV
  static Future<void> exportMeetings(List<Meeting> meetings, {String? filename}) async {
    try {
      final csvData = _generateMeetingsCsv(meetings);
      final fileName = filename ?? 'meetings_${_getTimestamp()}.csv';

      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting meetings: $e');
      rethrow;
    }
  }

  // Export on stays to CSV
  static Future<void> exportOnStays(List<OnStay> onStays, {String? filename}) async {
    try {
      final csvData = _generateOnStaysCsv(onStays);
      final fileName = filename ?? 'on_stays_${_getTimestamp()}.csv';

      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting on stays: $e');
      rethrow;
    }
  }

  // Export direct bookings to CSV
  static Future<void> exportDirectBookings(List<DirectBooking> directBookings, {String? filename}) async {
    try {
      final csvData = _generateDirectBookingsCsv(directBookings);
      final fileName = filename ?? 'direct_bookings_${_getTimestamp()}.csv';

      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting direct bookings: $e');
      rethrow;
    }
  }

  // Export polaroids to CSV
  static Future<void> exportPolaroids(List<Polaroid> polaroids, {String? filename}) async {
    try {
      final csvData = _generatePolaroidsCsv(polaroids);
      final fileName = filename ?? 'polaroids_${_getTimestamp()}.csv';

      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting polaroids: $e');
      rethrow;
    }
  }

  // Generate CSV for events
  static String _generateEventsCsv(List<Event> events) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Type',
      'Client Name',
      'Date',
      'End Date',
      'Start Time',
      'End Time',
      'Location',
      'Day Rate',
      'Usage Rate',
      'Currency',
      'Status',
      'Payment Status',
      'Option Status',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final event in events) {
      buffer.writeln([
        event.type.displayName,
        event.clientName ?? '',
        event.date != null ? DateFormat('yyyy-MM-dd').format(event.date!) : '',
        event.endDate != null ? DateFormat('yyyy-MM-dd').format(event.endDate!) : '',
        event.startTime ?? '',
        event.endTime ?? '',
        event.location ?? '',
        event.dayRate?.toString() ?? '',
        event.usageRate?.toString() ?? '',
        event.currency ?? '',
        event.status?.toString().split('.').last ?? '',
        event.paymentStatus?.toString().split('.').last ?? '',
        event.optionStatus?.toString().split('.').last ?? '',
        event.notes ?? '',
        event.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(event.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for jobs
  static String _generateJobsCsv(List<Job> jobs) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Client Name',
      'Type',
      'Date',
      'Time',
      'End Time',
      'Location',
      'Rate',
      'Currency',
      'Payment Status',
      'Status',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final job in jobs) {
      buffer.writeln([
        job.clientName,
        job.type,
        job.createdDate != null ? DateFormat('yyyy-MM-dd').format(job.createdDate!) : '',
        job.time ?? '',
        job.endTime ?? '',
        job.location,
        job.rate.toString(),
        job.currency ?? '',
        job.paymentStatus ?? '',
        job.status ?? '',
        job.notes ?? '',
        job.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(job.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for agents
  static String _generateAgentsCsv(List<Agent> agents) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Name',
      'Email',
      'Phone',
      'Agency',
      'City',
      'Country',
      'Instagram',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final agent in agents) {
      buffer.writeln([
        agent.name,
        agent.email ?? '',
        agent.phone ?? '',
        agent.agency ?? '',
        agent.city ?? '',
        agent.country ?? '',
        agent.instagram ?? '',
        agent.notes ?? '',
        agent.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(agent.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for agencies
  static String _generateAgenciesCsv(List<Agency> agencies) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Name',
      'Type',
      'Website',
      'Address',
      'City',
      'Country',
      'Commission Rate',
      'Main Booker Name',
      'Main Booker Email',
      'Main Booker Phone',
      'Finance Contact Name',
      'Finance Contact Email',
      'Finance Contact Phone',
      'Contract Signed',
      'Contract Expired',
      'Status',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final agency in agencies) {
      buffer.writeln([
        agency.name,
        agency.agencyType ?? '',
        agency.website ?? '',
        agency.address ?? '',
        agency.city ?? '',
        agency.country ?? '',
        agency.commissionRate.toString(),
        agency.mainBooker?.name ?? '',
        agency.mainBooker?.email ?? '',
        agency.mainBooker?.phone ?? '',
        agency.financeContact?.name ?? '',
        agency.financeContact?.email ?? '',
        agency.financeContact?.phone ?? '',
        agency.contractSigned != null ? DateFormat('yyyy-MM-dd').format(agency.contractSigned!) : '',
        agency.contractExpired != null ? DateFormat('yyyy-MM-dd').format(agency.contractExpired!) : '',
        agency.status ?? '',
        agency.notes ?? '',
        agency.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(agency.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for castings
  static String _generateCastingsCsv(List<Casting> castings) {
    final buffer = StringBuffer();

    // Headers
    buffer.writeln([
      'Title',
      'Description',
      'Date',
      'Location',
      'Requirements',
      'Status',
      'Client Name',
      'Rate',
      'Currency'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final casting in castings) {
      buffer.writeln([
        casting.title,
        casting.description ?? '',
        DateFormat('yyyy-MM-dd').format(casting.date),
        casting.location ?? '',
        casting.requirements ?? '',
        casting.status,
        casting.clientName ?? '',
        casting.rate?.toString() ?? '',
        casting.currency ?? '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for tests
  static String _generateTestsCsv(List<Test> tests) {
    final buffer = StringBuffer();

    // Headers
    buffer.writeln([
      'Title',
      'Description',
      'Date',
      'Location',
      'Requirements',
      'Status',
      'Client Name',
      'Rate',
      'Currency'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final test in tests) {
      buffer.writeln([
        test.title,
        test.description ?? '',
        DateFormat('yyyy-MM-dd').format(test.date),
        test.location ?? '',
        test.requirements ?? '',
        test.status,
        test.clientName ?? '',
        test.rate?.toString() ?? '',
        test.currency ?? '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for meetings
  static String _generateMeetingsCsv(List<Meeting> meetings) {
    final buffer = StringBuffer();

    // Headers
    buffer.writeln([
      'Client Name',
      'Type',
      'Date',
      'Location',
      'Status',
      'Rate',
      'Notes'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final meeting in meetings) {
      buffer.writeln([
        meeting.clientName,
        meeting.type ?? '',
        meeting.date,
        meeting.location ?? '',
        meeting.status ?? '',
        meeting.rate ?? '',
        meeting.notes ?? '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for on stays
  static String _generateOnStaysCsv(List<OnStay> onStays) {
    final buffer = StringBuffer();

    // Headers
    buffer.writeln([
      'Location Name',
      'Stay Type',
      'Address',
      'Check-in Date',
      'Check-out Date',
      'Check-in Time',
      'Check-out Time',
      'Cost',
      'Currency',
      'Status',
      'Payment Status',
      'Notes'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final onStay in onStays) {
      buffer.writeln([
        onStay.locationName,
        onStay.stayType ?? '',
        onStay.address ?? '',
        onStay.checkInDate != null ? DateFormat('yyyy-MM-dd').format(onStay.checkInDate!) : '',
        onStay.checkOutDate != null ? DateFormat('yyyy-MM-dd').format(onStay.checkOutDate!) : '',
        onStay.checkInTime ?? '',
        onStay.checkOutTime ?? '',
        onStay.cost.toString(),
        onStay.currency,
        onStay.status,
        onStay.paymentStatus,
        onStay.notes ?? '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for direct bookings
  static String _generateDirectBookingsCsv(List<DirectBooking> directBookings) {
    final buffer = StringBuffer();

    // Headers
    buffer.writeln([
      'Client Name',
      'Booking Type',
      'Location',
      'Booking Agent',
      'Date',
      'Start Time',
      'End Time',
      'Rate',
      'Currency',
      'Extra Hours',
      'Agency Fee %',
      'Tax %',
      'Additional Fees',
      'Phone',
      'Email',
      'Status',
      'Payment Status',
      'Notes'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final booking in directBookings) {
      buffer.writeln([
        booking.clientName,
        booking.bookingType ?? '',
        booking.location ?? '',
        booking.bookingAgent ?? '',
        booking.date != null ? DateFormat('yyyy-MM-dd').format(booking.date!) : '',
        booking.time ?? '',
        booking.endTime ?? '',
        booking.rate?.toString() ?? '',
        booking.currency ?? 'USD',
        booking.extraHours ?? '',
        booking.agencyFeePercentage ?? '',
        booking.taxPercentage ?? '',
        booking.additionalFees ?? '',
        booking.phone ?? '',
        booking.email ?? '',
        booking.status ?? '',
        booking.paymentStatus ?? '',
        booking.notes ?? '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for polaroids
  static String _generatePolaroidsCsv(List<Polaroid> polaroids) {
    final buffer = StringBuffer();

    // Headers
    buffer.writeln([
      'Client Name',
      'Type',
      'Location',
      'Booking Agent',
      'Date',
      'Start Time',
      'End Time',
      'Rate',
      'Currency',
      'Status',
      'Notes'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final polaroid in polaroids) {
      buffer.writeln([
        polaroid.clientName,
        polaroid.type ?? '',
        polaroid.location ?? '',
        polaroid.bookingAgent ?? '',
        polaroid.date,
        polaroid.time ?? '',
        polaroid.endTime ?? '',
        polaroid.rate?.toString() ?? '',
        polaroid.currency ?? 'USD',
        polaroid.status ?? '',
        polaroid.notes ?? '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Escape CSV field (handle commas, quotes, newlines)
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // Get timestamp for filename
  static String _getTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  // Share file on mobile/desktop
  static Future<void> _shareFile(String content, String filename) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use share_plus
      await SharePlus.instance.share(ShareParams(text: content));
    } else {
      // Desktop: Save to downloads folder
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
        debugPrint('File saved to: ${file.path}');
      }
    }
  }

  // Download file on web
  static Future<void> _downloadWebFile(String content, String filename) async {
    try {
      // Create data URL with CSV content
      final bytes = utf8.encode(content);
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:text/csv;charset=utf-8;base64,$base64Data';

      // Create download URL
      final downloadUrl = Uri.parse(dataUrl);

      if (await canLaunchUrl(downloadUrl)) {
        await launchUrl(
          downloadUrl,
          mode: LaunchMode.platformDefault,
        );
        debugPrint('Web download initiated for: $filename');
      } else {
        debugPrint('Could not launch download URL for web');

        // Fallback: Try to open in new tab
        await launchUrl(
          downloadUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Web download error: $e');
      // Additional fallback: show content in new tab
      try {
        final contentUrl = Uri.dataFromString(
          content,
          mimeType: 'text/csv',
          encoding: utf8,
        );
        await launchUrl(contentUrl, mode: LaunchMode.externalApplication);
      } catch (fallbackError) {
        debugPrint('Fallback web download also failed: $fallbackError');
      }
    }
  }
}
