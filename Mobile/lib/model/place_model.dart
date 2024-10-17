import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceInfo {
  final String city;
  final String destinationName;
  final double latitude;
  final double longitude;
  final String description;
  final String destinationType;
  final String? image;
  final List<int> bestMonths;  // New field to store best months
  final String? destination;

  PlaceInfo({
    required this.city,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.destinationType = 'local',
    this.image,
    required this.bestMonths,  // Include this in constructor
    required this.destination,
  });

  // Factory method to create PlaceInfo from JSON and hard-code bestMonths
  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
  // Assign bestMonths based on city name
  List<int> bestMonths = [];

  String city = json['city'] ?? 'Unknown City'; // Provide a default value if city is null
  switch (city.toLowerCase()) {
    case 'baguio':
      bestMonths = [3, 4, 5, 10, 11, 12];
      break;
    case 'bohol':
      bestMonths = [12, 1, 2, 3, 4, 5];  // February
      break;
    case 'batanes':
      bestMonths = [3, 4, 5, 6, 7];  // February
      break;
    case 'boracay':
      bestMonths = [2, 3, 4, 5, 8, 9];  // February
      break;
    case 'cebu':
      bestMonths = [4, 5, 6, 7, 8, 9];  // February
      break;
    // Add other city cases as needed
    default:
      bestMonths = [];  // No best months
  }

  return PlaceInfo(
    city: city,
    destinationName: json['destinationName'],
    latitude: json['latitude'].toDouble(),
    longitude: json['longitude'].toDouble(),
    description: json['description'],
    destinationType: json['destinationType'] ?? 'local',
    image: json['image'] ?? 'assets/default_image.jpg',  // Provide a default image path if null
    bestMonths: bestMonths,
    destination: json['destination'] ?? 'Unknown Destination',
  );
}

}

// Function to fetch places from the API
Future<List<PlaceInfo>> fetchDestinations() async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/places'));
print("API Response: ${response.body}");  // Add this line to see the raw response

  // Check if the response is successful
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    // Map the JSON response to List<PlaceInfo>
    return jsonResponse.map((place) => PlaceInfo.fromJson(place)).toList();
  } else {
    // Handle errors if the response is not successful
    throw Exception('Failed to load destinations');
  }
}
