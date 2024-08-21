import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class AdminCancellationPage extends StatefulWidget {
  @override
  _AdminCancellationPageState createState() => _AdminCancellationPageState();
}

class _AdminCancellationPageState extends State<AdminCancellationPage> {
  final DateFormat _dateFormat =
      DateFormat('yyyy-MM-dd'); // Format for date only

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Cancellations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('cancellation_requested', isEqualTo: true)
            .where('cancellation_approved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var bookings = snapshot.data!.docs;
          if (bookings.isEmpty) {
            return Center(child: Text('No cancellation requests.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              var startDate = (booking['start_date'] as Timestamp).toDate();
              var endDate = (booking['end_date'] as Timestamp).toDate();
              return ListTile(
                title: Text('Booking ID: ${booking.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer ID: ${booking['customer_id']}'),
                    Text('Start Date: ${_dateFormat.format(startDate)}'),
                    Text('End Date: ${_dateFormat.format(endDate)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _approveCancellation(booking.id),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _rejectCancellation(booking.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveCancellation(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'cancellation_approved': true,
      'status': 'cancelled',
    });
  }

  Future<void> _rejectCancellation(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'cancellation_approved': false,
      'cancellation_requested': false,
      'status': 'active',
    });
  }
}
