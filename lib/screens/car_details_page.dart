import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorq/screens/booking_page.dart';
import 'package:motorq/widgets/wishlist.dart';

class CarDetailsPage extends StatefulWidget {
  final Map<String, dynamic> car;
  final String car_id;

  CarDetailsPage({required this.car, required this.car_id});

  @override
  _CarDetailsPageState createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  String _bookingStatus = 'Checking...'; // Default status text
  double _currentRating = 0;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.car['rating']?.toDouble() ?? 0;
    imageUrl = widget.car['imageUrl'];
    _fetchBookingStatus();
  }

  Future<void> _fetchBookingStatus() async {
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('car_id', isEqualTo: widget.car_id)
        .where('status', isEqualTo: 'confirmed')
        .get();

    if (bookingsSnapshot.docs.isNotEmpty) {
      setState(() {
        _bookingStatus = 'Booked';
      });
    } else {
      setState(() {
        _bookingStatus = 'Available';
      });
    }
  }

  Future<void> _addToWishlist() async {
    String customerId =
        "eHnOta8h3sAqSNa2hWvB"; // Replace with actual customer ID

    // Add the car to the wishlist
    await addToWishlist(customerId, widget.car_id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Car added to wishlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.car['make']} ${widget.car['model']}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the car image if available
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Center(
                  child: Image.network(
                    imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Text('Make: ${widget.car['make']}'),
              Text('Model: ${widget.car['model']}'),
              Text('Year: ${widget.car['year']}'),
              Text('Rent Rate: \$${widget.car['rent_rate']} per day'),
              const SizedBox(height: 20),
              Text('Average Rating: $_currentRating'),
              Text('Status: $_bookingStatus'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final carId = widget.car_id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(carId: carId),
                    ),
                  );
                },
                child: const Text('Book This Car'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addToWishlist,
                child: const Text('Add to Wishlist'),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _submitRating(context, widget.car_id, rating);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRating(BuildContext context, String carId, double rating) async {
    String customerId =
        "eHnOta8h3sAqSNa2hWvB"; // Replace with actual customer ID

    CollectionReference ratings =
        FirebaseFirestore.instance.collection('ratings');

    // Check if the customer has already rated this car
    QuerySnapshot existingRating = await ratings
        .where('car_id', isEqualTo: carId)
        .where('customer_id', isEqualTo: customerId)
        .get();

    if (existingRating.docs.isEmpty) {
      // Add new rating
      await ratings.add({
        'car_id': carId,
        'customer_id': customerId,
        'rating': rating,
      });
    } else {
      // Update existing rating
      DocumentReference ratingDoc = existingRating.docs.first.reference;
      await ratingDoc.update({
        'rating': rating,
      });
    }

    // Update the car's global rating
    _updateGlobalRating(carId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rating submitted')),
    );
  }

  void _updateGlobalRating(String carId) async {
    CollectionReference ratings =
        FirebaseFirestore.instance.collection('ratings');

    QuerySnapshot allRatings =
        await ratings.where('car_id', isEqualTo: carId).get();

    double totalRating = 0;
    int ratingCount = allRatings.docs.length;

    for (var doc in allRatings.docs) {
      totalRating += (doc.data() as Map<String, dynamic>)['rating'];
    }

    double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0;

    // Update the global rating in the car's document
    DocumentReference carRef =
        FirebaseFirestore.instance.collection('cars').doc(carId);
    await carRef.update({
      'rating': averageRating,
    });
  }
}
