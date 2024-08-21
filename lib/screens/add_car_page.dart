import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCarPage extends StatefulWidget {
  final String adminId;

  AddCarPage({required this.adminId});

  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController();
  final TextEditingController rentRateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();
  String? _imageUrl;

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future uploadImage() async {
    if (_imageFile == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('car_images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(_imageFile!);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Make'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              TextField(
                controller: fuelTypeController,
                decoration: const InputDecoration(labelText: 'Fuel Type'),
              ),
              TextField(
                controller: rentRateController,
                decoration: const InputDecoration(labelText: 'Rent Rate'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: licenseNumberController,
                decoration: const InputDecoration(labelText: 'License Number'),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : const Icon(Icons.add_a_photo, size: 50),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await uploadImage(); // Upload the image to Firebase Storage

                  await FirebaseFirestore.instance.collection('cars').add({
                    'make': makeController.text,
                    'model': modelController.text,
                    'year': int.parse(yearController.text),
                    'fuel_type': fuelTypeController.text,
                    'rent_rate': int.parse(rentRateController.text),
                    'location': locationController.text,
                    'status': 'available',
                    'customer_id': null,
                    'rating': 0,
                    'admin_id': widget.adminId,
                    'license_number': licenseNumberController.text,
                    'imageUrl': _imageUrl ?? '',
                  });

                  Navigator.pop(context);
                },
                child: const Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
