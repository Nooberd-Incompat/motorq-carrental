import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addToWishlist(String customerId, String carId) async {
  CollectionReference wishlist =
      FirebaseFirestore.instance.collection('wishlist');

  return wishlist
      .add({
        'customer_id': customerId,
        'car_id': carId,
        'created_at': FieldValue.serverTimestamp(),
      })
      .then((value) => print("Car Added to Wishlist"))
      .catchError((error) => print("Failed to add to wishlist: $error"));
}

Stream<QuerySnapshot> getWishlist(String customerId) {
  CollectionReference wishlist =
      FirebaseFirestore.instance.collection('wishlist');
  return wishlist.where('customer_id', isEqualTo: customerId).snapshots();
}

Future<void> removeFromWishlist(String wishlistId) async {
  CollectionReference wishlist =
      FirebaseFirestore.instance.collection('wishlist');

  return wishlist
      .doc(wishlistId)
      .delete()
      .then((value) => print("Car Removed from Wishlist"))
      .catchError((error) => print("Failed to remove from wishlist: $error"));
}
