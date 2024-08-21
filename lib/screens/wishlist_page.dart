import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorq/screens/car_details_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    String customerId =
        "eHnOta8h3sAqSNa2hWvB"; // Replace with the actual customer ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wishlist')
            .where('customer_id', isEqualTo: customerId) // Corrected field name
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var wishlistDocs = snapshot.data!.docs;

          if (wishlistDocs.isEmpty) {
            return Center(child: Text('Your wishlist is empty'));
          }

          return ListView.builder(
            itemCount: wishlistDocs.length,
            itemBuilder: (context, index) {
              var wishlistItem =
                  wishlistDocs[index].data() as Map<String, dynamic>;
              String carId = wishlistItem['car_id'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cars')
                    .doc(carId)
                    .get(),
                builder: (context, carSnapshot) {
                  if (!carSnapshot.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  var carData =
                      carSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text('${carData['make']} ${carData['model']}'),
                    subtitle: Text('Rent: \$${carData['rent_rate']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await wishlistDocs[index].reference.delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Car removed from wishlist')),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetailsPage(
                            car: carData,
                            car_id: carId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
