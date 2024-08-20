import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateCarLocationAndStatus(
    String carId, String location, String status) async {
  CollectionReference cars = FirebaseFirestore.instance.collection('cars');

  return cars
      .doc(carId)
      .update({
        'location': location,
        'status': status,
      })
      .then((value) => print("Car Location and Status Updated"))
      .catchError(
          (error) => print("Failed to update car location and status: $error"));
}

Stream<DocumentSnapshot> getCarLocationAndStatus(String carId) {
  CollectionReference cars = FirebaseFirestore.instance.collection('cars');
  return cars.doc(carId).snapshots();
}
