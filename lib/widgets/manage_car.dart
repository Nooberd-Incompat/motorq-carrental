import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addCar(String make, String model, int year, String licenseNumber,
    double rentRate, String location) async {
  CollectionReference cars = FirebaseFirestore.instance.collection('cars');

  return cars
      .add({
        'make': make,
        'model': model,
        'year': year,
        'license_number': licenseNumber,
        'rent_rate': rentRate,
        'location': location,
        'status': 'available',
        'current_customer_id': null,
        'rating': null,
      })
      .then((value) => print("Car Added"))
      .catchError((error) => print("Failed to add car: $error"));
}

Stream<QuerySnapshot> getCars({String? make, String? model, int? year}) {
  CollectionReference cars = FirebaseFirestore.instance.collection('cars');
  Query query = cars;

  if (make != null) query = query.where('make', isEqualTo: make);
  if (model != null) query = query.where('model', isEqualTo: model);
  if (year != null) query = query.where('year', isEqualTo: year);

  return query.snapshots();
}

Future<void> updateCarStatus(String carId, String status,
    {String? customerId}) async {
  CollectionReference cars = FirebaseFirestore.instance.collection('cars');

  return cars
      .doc(carId)
      .update({
        'status': status,
        'current_customer_id': customerId,
      })
      .then((value) => print("Car Status Updated"))
      .catchError((error) => print("Failed to update car status: $error"));
}

Future<void> deleteCar(String carId) async {
  CollectionReference cars = FirebaseFirestore.instance.collection('cars');

  return cars
      .doc(carId)
      .delete()
      .then((value) => print("Car Deleted"))
      .catchError((error) => print("Failed to delete car: $error"));
}
