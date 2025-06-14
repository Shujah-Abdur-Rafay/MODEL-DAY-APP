import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/models/direct_booking.dart';
import 'package:new_flutter/pages/new_direct_booking_page.dart';
import 'package:new_flutter/services/direct_bookings_service.dart';

class EditDirectBookingPage extends StatelessWidget {
  const EditDirectBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the booking from arguments
    final arguments = ModalRoute.of(context)?.settings.arguments;

    debugPrint('🔍 EditDirectBookingPage - Arguments type: ${arguments.runtimeType}');
    if (arguments is DirectBooking) {
      debugPrint('🔍 EditDirectBookingPage - Booking ID: ${arguments.id}');
      debugPrint('🔍 EditDirectBookingPage - Client Name: ${arguments.clientName}');
      // Pass the booking to the NewDirectBookingPage for editing
      return NewDirectBookingPage(editingBooking: arguments);
    } else if (arguments is String) {
      // If we only have an ID, we need to fetch the booking
      return AppLayout(
        currentPage: '/edit-direct-booking',
        title: 'Edit Direct Booking',
        child: FutureBuilder<DirectBooking?>(
          future: _fetchBookingById(arguments),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading booking: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              return NewDirectBookingPage(editingBooking: snapshot.data!);
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Booking not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
    } else {
      return AppLayout(
        currentPage: '/edit-direct-booking',
        title: 'Edit Direct Booking',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Invalid booking data'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<DirectBooking?> _fetchBookingById(String id) async {
    return await DirectBookingsService.getById(id);
  }
}
