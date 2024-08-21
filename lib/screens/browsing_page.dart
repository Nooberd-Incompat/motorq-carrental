import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorq/screens/booking_page.dart';
import 'package:motorq/screens/car_details_page.dart';

class BrowseCarsPage extends StatefulWidget {
  @override
  _BrowseCarsPageState createState() => _BrowseCarsPageState();
}

class _BrowseCarsPageState extends State<BrowseCarsPage> {
  String? _selectedFuelType;
  String? _selectedMake;
  String? _selectedModel;
  int? _selectedYear;
  double _minRent = 0;
  double _maxRent = 500; // Adjust the max rent based on your requirements

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Cars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Car List
          Expanded(
            child: _buildCarList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredCars(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var cars = snapshot.data!.docs;

        return ListView.builder(
          itemCount: cars.length,
          itemBuilder: (context, index) {
            var car = cars[index].data() as Map<String, dynamic>;
            var carId = cars[index].id;

            return ListTile(
              title: Text('${car['make']} ${car['model']} (${car['year']})'),
              subtitle: Text('Rent: \$${car['rent_rate']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarDetailsPage(
                      car: car,
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
  }

  Stream<QuerySnapshot> _getFilteredCars() {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');

    Query query = cars;

    if (_selectedFuelType != null) {
      query = query.where('fuel_type', isEqualTo: _selectedFuelType);
    }
    if (_selectedMake != null) {
      query = query.where('make', isEqualTo: _selectedMake);
    }
    if (_selectedModel != null) {
      query = query.where('model', isEqualTo: _selectedModel);
    }
    if (_selectedYear != null) {
      query = query.where('year', isEqualTo: _selectedYear);
    }
    query = query
        .where('rent_rate', isGreaterThanOrEqualTo: _minRent)
        .where('rent_rate', isLessThanOrEqualTo: _maxRent);

    return query.snapshots();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Cars'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ensure dialog content is not oversized
              children: [
                // Fuel Type Dropdown
                DropdownButton<String>(
                  hint: const Text('Select Fuel Type'),
                  value: _selectedFuelType,
                  items: ['Petrol', 'Diesel', 'Electric']
                      .map((fuelType) => DropdownMenuItem<String>(
                            value: fuelType,
                            child: Text(fuelType),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFuelType = value;
                      _applyFilters();
                    });
                  },
                ),
                // Make Dropdown
                DropdownButton<String>(
                  hint: const Text('Select Make'),
                  value: _selectedMake,
                  items: [
                    'Toyota',
                    'Honda',
                    'Ford',
                    'Tesla'
                  ] // Add more makes as needed
                      .map((make) => DropdownMenuItem<String>(
                            value: make,
                            child: Text(make),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMake = value;
                      _applyFilters();
                    });
                  },
                ),
                // Model Dropdown
                DropdownButton<String>(
                  hint: Text('Select Model'),
                  value: _selectedModel,
                  items:
                      ['Model A', 'Model B', 'S'] // Add more models as needed
                          .map((model) => DropdownMenuItem<String>(
                                value: model,
                                child: Text(model),
                              ))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedModel = value;
                      _applyFilters();
                    });
                  },
                ),
                // Year Dropdown
                DropdownButton<int>(
                  hint: const Text('Select Year'),
                  value: _selectedYear,
                  items: [
                    2015,
                    2016,
                    2017,
                    2018,
                    2019,
                    2020,
                    2021,
                    2022
                  ] // Add more years as needed
                      .map((year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                      _applyFilters();
                    });
                  },
                ),
                // Rent Range Slider
                RangeSlider(
                  values: RangeValues(_minRent, _maxRent),
                  min: 0,
                  max: 1000, // Adjust max rent as needed
                  divisions: 10,
                  labels: RangeLabels(
                    '\$${_minRent.toStringAsFixed(2)}',
                    '\$${_maxRent.toStringAsFixed(2)}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _minRent = values.start;
                      _maxRent = values.end;
                      // _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    // Get filtered cars based on current selections
    Stream<QuerySnapshot> filteredCars = _getFilteredCars();

    // Replace the existing stream in the StreamBuilder with the filtered stream
    setState(() {
      // This will trigger a rebuild of the StreamBuilder in _buildCarList
    });

    Navigator.of(context).pop(); // Close the filter dialog
  }
}