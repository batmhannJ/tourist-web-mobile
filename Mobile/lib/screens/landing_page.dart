import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final List<String> mostSearchedDestinations;

  const LandingPage({super.key, required this.mostSearchedDestinations}); // Accepting the list as a parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Data Analytics'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Most Searched Destination',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Display the most searched destinations
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
      ),
    );
  }
}
