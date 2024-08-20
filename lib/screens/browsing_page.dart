import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorq/screens/car_details_page.dart';

class CarBrowsingPage extends StatefulWidget {
  const CarBrowsingPage({super.key});

  @override
  _CarBrowsingPageState createState() => _CarBrowsingPageState();
}

class _CarBrowsingPageState extends State<CarBrowsingPage> {
  String selectedFuelType = 'All';
  double rentRange = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Cars'),
      ),
      body: Column(
        children: [
          // Filters
          DropdownButton<String>(
            value: selectedFuelType,
            items: ['All', 'Petrol', 'Diesel', 'Electric']
                .map((fuelType) => DropdownMenuItem(
                      value: fuelType,
                      child: Text(fuelType),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedFuelType = value!;
              });
            },
          ),
          Slider(
            value: rentRange,
            min: 0,
            max: 500,
            divisions: 10,
            label: rentRange.round().toString(),
            onChanged: (value) {
              setState(() {
                rentRange = value;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cars')
                  .where('fuel_type',
                      isEqualTo:
                          selectedFuelType == 'All' ? null : selectedFuelType)
                  .where('rent_rate', isLessThanOrEqualTo: rentRange)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var cars = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    var car = cars[index];
                    return ListTile(
                      title: Text(
                          '${car['make']} ${car['model']} (${car['year']})'),
                      subtitle: Text('Rent: \$${car['rent_rate']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailsPage(carId: car.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
