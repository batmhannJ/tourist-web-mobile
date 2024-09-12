import 'package:flutter/material.dart';

class ProfileAccountPage extends StatelessWidget {
  const ProfileAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Account'),
              onTap: () {
                // lagay dito functionality
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('View Data Analytics'),
              onTap: () {
                
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
               
              },
            ),
          ],
        ),
      ),
    );
  }
}
