import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addRating(
    String carId, String customerId, int rating, String comment) async {
  CollectionReference ratings =
      FirebaseFirestore.instance.collection('ratings');

  return ratings
      .add({
        'car_id': carId,
        'customer_id': customerId,
        'rating': rating,
        'comment': comment,
        'created_at': FieldValue.serverTimestamp(),
      })
      .then((value) => print("Rating Added"))
      .catchError((error) => print("Failed to add rating: $error"));
}

Stream<QuerySnapshot> getRatings(String carId) {
  CollectionReference ratings =
      FirebaseFirestore.instance.collection('ratings');
  return ratings.where('car_id', isEqualTo: carId).snapshots();
}

Future<void> updateCarRating(String carId) async {
  CollectionReference ratings =
      FirebaseFirestore.instance.collection('ratings');
  QuerySnapshot ratingDocs =
      await ratings.where('car_id', isEqualTo: carId).get();

  if (ratingDocs.docs.isNotEmpty) {
    double totalRating = 0;
    ratingDocs.docs.forEach((doc) {
      totalRating += doc['rating'];
    });

    double averageRating = totalRating / ratingDocs.docs.length;

    CollectionReference cars = FirebaseFirestore.instance.collection('cars');
    cars
        .doc(carId)
        .update({
          'rating': averageRating,
        })
        .then((value) => print("Car Rating Updated"))
        .catchError((error) => print("Failed to update car rating: $error"));
  }
}
