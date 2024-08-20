import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarDetailsPage extends StatelessWidget {
  final String carId;

  CarDetailsPage({required this.carId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('cars').doc(carId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var car = snapshot.data!;
          return Column(
            children: [
              Text('${car['make']} ${car['model']} (${car['year']})'),
              Text('Rent: \$${car['rent_rate']} per day'),
              Text('Rating: ${car['rating'] ?? 'No ratings yet'}'),
              ElevatedButton(
                onPressed: () {
                  // Implement booking function here
                },
                child: Text('Book Now'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement wishlist addition here
                },
                child: Text('Add to Wishlist'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement rating function here
                },
                child: Text('Rate this Car'),
              ),
            ],
          );
        },
      ),
    );
  }
}
