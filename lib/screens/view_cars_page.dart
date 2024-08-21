import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCarsPage extends StatefulWidget {
  final String adminId;

  const ViewCarsPage({Key? key, required this.adminId}) : super(key: key);

  @override
  _ViewCarsPageState createState() => _ViewCarsPageState();
}

class _ViewCarsPageState extends State<ViewCarsPage> {
  String selectedFilter = 'make'; // Default filter
  String filterValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Cars'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter selection
            Row(
              children: [
                Text('Filter by:'),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'make',
                      child: Text('Make'),
                    ),
                    DropdownMenuItem(
                      value: 'model',
                      child: Text('Model'),
                    ),
                    DropdownMenuItem(
                      value: 'year',
                      child: Text('Year'),
                    ),
                    DropdownMenuItem(
                      value: 'license_number',
                      child: Text('Registration Number'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // Input for filter value
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter $selectedFilter',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  filterValue = value;
                });
              },
            ),
            SizedBox(height: 20),
            // Display filtered cars
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var cars = snapshot.data!.docs;
                  if (cars.isEmpty) {
                    return Center(child: Text('No cars found.'));
                  }
                  return ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      var car = cars[index];
                      return ListTile(
                        title: Text(
                            '${car['make']} ${car['model']} (${car['year']})'),
                        subtitle:
                            Text('Registration: ${car['license_number']}'),
                        trailing: Text('Rent: \$${car['rent_rate']}'),
                        onTap: () {
                          // Navigate to car details or edit page
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _buildStream() {
    // Create a reference to the 'cars' collection
    var query = FirebaseFirestore.instance
        .collection('cars')
        .where('admin_id', isEqualTo: widget.adminId);

    // Add filter based on filterValue if it's not empty
    if (filterValue.isNotEmpty) {
      query = query.where(selectedFilter, isEqualTo: filterValue);
    }

    return query.snapshots();
  }
}
