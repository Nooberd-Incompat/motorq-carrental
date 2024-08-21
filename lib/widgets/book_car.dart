import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motorq/widgets/manage_car.dart';

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

isCarAvailable(
    String carId, DateTime desiredStartDate, DateTime desiredEndDate) async {
  DocumentSnapshot carDoc =
      await FirebaseFirestore.instance.collection('cars').doc(carId).get();

  // Check if the car's status is available
  if (carDoc['status'] != 'available') {
    return false;
  }

  // Check for date overlaps
  QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
      .collection('bookings')
      .where('car_id', isEqualTo: carId)
      .get();

  for (var booking in bookingsSnapshot.docs) {
    DateTime startDate = booking['start_date'].toDate();
    DateTime endDate = booking['end_date'].toDate();

    if (desiredStartDate.isBefore(endDate) &&
        desiredEndDate.isAfter(startDate)) {
      return false; // Overlap found, car is not available
    }
  }

  return true; // No overlap and status is available
}

Future<void> bookCar(String customerId, String carId, DateTime startDate,
    DateTime endDate) async {
  bool available = await isCarAvailable(carId, startDate, endDate);

  if (available) {
    CollectionReference bookings =
        FirebaseFirestore.instance.collection('bookings');

    return bookings.add({
      'car_id': carId,
      'customer_id': customerId,
      'start_date': startDate,
      'end_date': endDate,
      'price': calculatePrice(carId, startDate, endDate),
      'status': 'confirmed',
    }).then((value) async {
      print("Booking Confirmed");
      await updateCarStatus(carId, 'booked', customerId: customerId);
      // Notify user about successful booking
      showSuccessMessage("Booking Confirmed!");
    }).catchError((error) => showErrorMessage("Failed to book car: $error"));
  } else {
    print("Car is not available");
    // Notify user about booking failure
    showErrorMessage(
        "Car is not available. Please choose a different car or time.");
  }
}

void showSuccessMessage(String message) {
  SnackBar(
    content: Text("yey, booking succesful!, $message"),
  );
}

void showErrorMessage(String message) {
  SnackBar(
    content: Text("oops, something went wrong! $message"),
  );
}

double calculatePrice(String carId, DateTime startDate, DateTime endDate) {
  // Example price calculation; adjust as needed
  return 100.0; // Placeholder value
}

// Function to request cancellation
Future<void> requestCancellation(String bookingId) async {
  CollectionReference bookings =
      FirebaseFirestore.instance.collection('bookings');

  return bookings
      .doc(bookingId)
      .update({
        'cancellation_requested': true,
        'status': 'pending_cancellation',
      })
      .then((value) => print("Cancellation Requested"))
      .catchError((error) => print("Failed to request cancellation: $error"));
}

// Function to handle the processing of cancellation
Future<void> processCancellation(String cancellationId, String status) async {
  CollectionReference cancellations =
      FirebaseFirestore.instance.collection('cancellations');

  return cancellations
      .doc(cancellationId)
      .update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      })
      .then((value) => print("Cancellation Processed"))
      .catchError((error) => print("Failed to process cancellation: $error"));
}

// Function to update booking status
Future<void> updateBookingStatus(String bookingId, String status) async {
  CollectionReference bookings =
      FirebaseFirestore.instance.collection('bookings');

  return bookings
      .doc(bookingId)
      .update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      })
      .then((value) => print("Booking Status Updated"))
      .catchError((error) => print("Failed to update booking status: $error"));
}
