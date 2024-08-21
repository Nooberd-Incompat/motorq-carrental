import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String customerId;

  const ProfilePage({super.key, required this.customerId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Upload the image to Firebase Storage
      String imageUrl = await _uploadImage(_image!);

      // Update the user's document in Firestore with the new image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.customerId)
          .update({'dl_image': imageUrl});
    }
  }

  Future<String> _uploadImage(File image) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('drivers_licenses/${widget.customerId}.jpg');

    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.customerId)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data found.'));
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String? imageUrl = userData['dl_image'];
            if (imageUrl == "null") {
              imageUrl = null;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Name: ${userData['name']}',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  imageUrl != null
                      ? Image.network(imageUrl)
                      : Column(
                          children: [
                            const Text(
                              'No driver\'s license image uploaded.',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: const Text('Upload Driver\'s License'),
                            ),
                          ],
                        ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
