import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('wishlist').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var wishlistItems = snapshot.data!.docs;
          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              var wishlistItem = wishlistItems[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cars')
                    .doc(wishlistItem['car_id'])
                    .get(),
                builder: (context, carSnapshot) {
                  if (!carSnapshot.hasData) return CircularProgressIndicator();
                  var car = carSnapshot.data!;
                  return ListTile(
                    title:
                        Text('${car['make']} ${car['model']} (${car['year']})'),
                    subtitle: Text('Rent: \$${car['rent_rate']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('wishlist')
                            .doc(wishlistItem.id)
                            .delete();
                      },
                    ),
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
