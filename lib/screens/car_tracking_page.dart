import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarTrackingPage extends StatefulWidget {
  final String adminId;

  const CarTrackingPage({Key? key, required this.adminId}) : super(key: key);

  @override
  _CarTrackingPageState createState() => _CarTrackingPageState();
}

class _CarTrackingPageState extends State<CarTrackingPage> {
  final Set<Marker> _markers = {};
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchCarLocations();
  }

  Future<void> _fetchCarLocations() async {
    final cars = await FirebaseFirestore.instance
        .collection('cars')
        .where('admin_id', isEqualTo: widget.adminId)
        .get();

    setState(() {
      _markers.clear();
      for (var doc in cars.docs) {
        final car = doc.data();
        final location = car['location']; // Assuming location is a GeoPoint

        if (location != null && location is GeoPoint) {
          final latLng = LatLng(location.latitude, location.longitude);
          _markers.add(
            Marker(
              point: latLng,
              width: 80.0,
              height: 80.0,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Cars'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(17.4064, 78.4771), // Default center location
          initialZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers.toList(),
          ),
        ],
      ),
    );
  }
}
