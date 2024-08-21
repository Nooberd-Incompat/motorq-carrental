import 'package:flutter/material.dart';
import 'package:motorq/screens/add_car_page.dart';
import 'package:motorq/screens/admin_cancellation_page.dart';
import 'package:motorq/screens/view_cars_page.dart';
import 'package:motorq/screens/car_tracking_page.dart';

class AdminDashboard extends StatelessWidget {
  final String adminId;

  AdminDashboard({required this.adminId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Add Car'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCarPage(adminId: adminId),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('View Cars'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCarsPage(
                    adminId: adminId,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Cancel Booking'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminCancellationPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Track Cars'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarTrackingPage(adminId: adminId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
