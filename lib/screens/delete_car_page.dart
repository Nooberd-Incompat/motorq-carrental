import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCarPage extends StatelessWidget {
  final DocumentSnapshot car;

  DeleteCarPage({required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Car'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('cars')
                .doc(car.id)
                .delete();
            Navigator.pop(context);
          },
          child: const Text('Confirm Deletion'),
        ),
      ),
    );
  }
}
