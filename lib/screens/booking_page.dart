import 'package:flutter/material.dart';
import 'package:motorq/widgets/book_car.dart';

class BookingPage extends StatefulWidget {
  final String carId;

  BookingPage({required this.carId});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Car')),
      body: Column(
        children: [
          // UI for selecting dates, etc.
          ElevatedButton(
            onPressed: () async {
              await bookCar('customerId', widget.carId, _startDate, _endDate);
            },
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }
}
