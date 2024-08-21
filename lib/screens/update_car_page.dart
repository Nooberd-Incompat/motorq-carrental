import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCarPage extends StatelessWidget {
  final DocumentSnapshot car;

  UpdateCarPage({super.key, required this.car});

  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();
  final TextEditingController rentRateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Initialize the controllers with the current values
    makeController.text = car['make'];
    modelController.text = car['model'];
    yearController.text = car['year'].toString();
    fuelTypeController.text = car['fuel_type'];
    rentRateController.text = car['rent_rate'].toString();
    locationController.text = car['location'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Car'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Make')),
            TextField(
                controller: modelController,
                decoration: InputDecoration(labelText: 'Model')),
            TextField(
                controller: yearController,
                decoration: InputDecoration(labelText: 'Year')),
            TextField(
                controller: fuelTypeController,
                decoration: InputDecoration(labelText: 'Fuel Type')),
            TextField(
                controller: rentRateController,
                decoration: InputDecoration(labelText: 'Rent Rate')),
            TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('cars')
                    .doc(car.id)
                    .update({
                  'make': makeController.text,
                  'model': modelController.text,
                  'year': int.parse(yearController.text),
                  'fuel_type': fuelTypeController.text,
                  'rent_rate': int.parse(rentRateController.text),
                  'location': locationController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Update Car'),
            ),
          ],
        ),
      ),
    );
  }
}
