import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageCarsPage()),
              );
            },
            child: Text('Manage Cars'),
          ),
          // Add more admin functionalities as needed
        ],
      ),
    );
  }
}

class ManageCarsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Cars'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var cars = snapshot.data!.docs;
          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              var car = cars[index];
              return ListTile(
                title: Text('${car['make']} ${car['model']} (${car['year']})'),
                subtitle: Text('Rent: \$${car['rent_rate']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('cars')
                        .doc(car.id)
                        .delete();
                  },
                ),
                onTap: () {
                  // Implement car status update or edit functionality
                },
              );
            },
          );
        },
      ),
    );
  }
}
