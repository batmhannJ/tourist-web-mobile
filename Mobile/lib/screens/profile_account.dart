import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAccountPage extends StatelessWidget {
  const ProfileAccountPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // Clear user session data (example: using SharedPreferences)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login screen
    Navigator.pushReplacementNamed(context, '/login_page'); // Change '/login' to your login route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Account'),
              onTap: () {
                // Add edit account functionality
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('View Data Analytics'),
              onTap: () {
                // Add data analytics functionality
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout(context); // Call the logout function when tapped
              },
            ),
          ],
        ),
      ),
    );
  }
}
