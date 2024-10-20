import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/map_page.dart'; // Import the MapPage
import 'package:flutter_application_2/model/place_model.dart'; // Import PlaceInfo model

class DetailScreen extends StatelessWidget {
  final PlaceInfo spot;  // Ensure you are using the PlaceInfo type

  const DetailScreen({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    // Debug print statement to inspect the data being passed
    print(spot);

    return Scaffold(
      appBar: AppBar(
        title: Text(spot.destinationName),  // Access properties using dot notation
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with rounded corners and shadow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    spot.image ?? 'assets/tagtay.jpg',  // Use dot notation here
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name of the tourist spot
              Text(
                spot.destinationName,  // Use dot notation here
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                spot.description,  // Use dot notation here
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Location coordinates with icons
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Latitude: ${spot.latitude}',  // Use dot notation here
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Longitude: ${spot.longitude}',  // Use dot notation here
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Explore More button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Convert latitude and longitude from String to double
                    double destinationLat = spot.latitude;
                    double destinationLong = spot.longitude;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(
                          destinationLat: destinationLat,
                          destinationLong: destinationLong,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Explore More',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
