import 'package:flutter/material.dart';

class Bookmark extends StatelessWidget {
  const Bookmark({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for demonstration
    final List<String> recommendedDestinations = [
      'Bora Bora',
      'Santorini',
      'New York City',
      'Tokyo',
      'Paris'
    ];

    final List<String> mostSearchedDestinations = [
      'London',
      'Dubai',
      'Rome',
      'Barcelona',
      'Sydney'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Destination Recommendations:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: recommendedDestinations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(recommendedDestinations[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Most Searched Destinations:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: mostSearchedDestinations.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(mostSearchedDestinations[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
