import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motorq/functions/email.dart';

class BookingPage extends StatefulWidget {
  final String carId;

  BookingPage({required this.carId});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateButton(
              label: 'Select Start Date',
              selectedDate: startDate,
              onDateSelected: (picked) {
                setState(() {
                  startDate = picked;
                });
              },
            ),
            SizedBox(height: 10),
            _buildDateButton(
              label: 'Select End Date',
              selectedDate: endDate,
              onDateSelected: (picked) {
                setState(() {
                  endDate = picked;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_validateDates()) {
                  await _confirmBooking();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select valid dates')),
                  );
                }
              },
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return ElevatedButton(
      onPressed: () async {
        DateTime initialDate = selectedDate ?? DateTime.now();
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Text(
        '$label: ${selectedDate != null ? selectedDate!.toLocal().toShortDateString() : 'Select'}',
      ),
    );
  }

  bool _validateDates() {
    if (startDate == null || endDate == null) return false;
    if (startDate!.isAfter(endDate!)) return false;
    return true;
  }

  Future<void> _confirmBooking() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('car_id', isEqualTo: widget.carId)
        .where('start_date', isLessThanOrEqualTo: endDate)
        .where('end_date', isGreaterThanOrEqualTo: startDate)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('bookings').add({
        'car_id': widget.carId,
        'customer_id':
            'eHnOta8h3sAqSNa2hWvB', // replace with actual customer ID
        'start_date': Timestamp.fromDate(startDate!),
        'end_date': Timestamp.fromDate(endDate!),
        'status': 'confirmed',
      });

      await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.carId)
          .update({'status': 'booked'});

      Future<void> notifyCustomer(
          String customerEmail, String bookingDetails) async {
        await sendEmail(
          customerEmail,
          'Booking Confirmation',
          'Your booking has been confirmed. Details: $bookingDetails',
        );
      }

      notifyCustomer("shashtasreeyojith.k22@iiits.in", "Booked");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Confirmed')),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car is not available for the selected dates')),
      );
    }
  }
}

extension DateTimeExtension on DateTime {
  String toShortDateString() {
    return "${this.year}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}";
  }
}
