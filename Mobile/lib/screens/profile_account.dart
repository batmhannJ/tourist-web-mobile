import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'edit_profile_page.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'package:flutter_application_2/providers/user_provider.dart';
import 'package:flutter_application_2/screens/landing_page.dart'; // Adjust the path according to your project structure

class ProfileAccountPage extends StatelessWidget {
  const ProfileAccountPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final AuthService authService =
        AuthService(); // Create an instance of AuthService
    await authService.logout(); // Call the logout method
    Navigator.pushReplacementNamed(context, '/login_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Profile Account'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          children: [
            // Profile Information Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  /*const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                  ),*/
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fetch and display user details from UserProvider
                      Text(
                        Provider.of<UserProvider>(context).user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(Provider.of<UserProvider>(context).user.email),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit Account Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text('Edit Account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditAccountPage()),
                  );
                },
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.orange),
              ),
            ),

            const SizedBox(height: 10),

            // View Data Analytics Card
            /*Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.orange),
                title: const Text('View Data Analytics'),
                onTap: () {
                  _navigateToLandingPage(context); // Call the method here
                },
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
              ),
            ),*/

            const SizedBox(height: 10),

            // Logout Button
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                _logout(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLandingPage(BuildContext context) {
    List<String> searchedDestinations = ['Tagaytay', 'Boracay', 'Palawan'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LandingPage(mostSearchedDestinations: searchedDestinations),
      ),
    );
  }
}
