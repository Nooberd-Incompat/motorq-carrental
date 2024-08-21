import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadLicensePage extends StatefulWidget {
  @override
  _UploadLicensePageState createState() => _UploadLicensePageState();
}

class _UploadLicensePageState extends State<UploadLicensePage> {
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      // Upload to Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('drivers_license/${pickedFile.name}');
      UploadTask uploadTask = ref.putFile(file);

      final TaskSnapshot downloadUrl = (await uploadTask);
      final String url = await downloadUrl.ref.getDownloadURL();

      setState(() {
        _imageUrl = url;
      });

      // Store the URL in Firestore
      _storeImageUrl(url);
    }
  }

  void _storeImageUrl(String url) {
    String customerId =
        "eHnOta8h3sAqSNa2hWvB"; // Replace with the actual customer ID

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(customerId);

    userRef.update({'dl_image': url}).then((_) {
      print("Driver's license image URL updated");
    }).catchError((error) {
      print("Failed to update image URL: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Driver\'s License'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageUrl != null
                ? Image.network(_imageUrl!)
                : Text('No image uploaded.'),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
