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
  final List<int> bestMonths; // New field to store best months
    final String? destination;


  PlaceInfo({
    required this.city,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.destinationType = 'local',
    this.image,
    required this.bestMonths, // Include this in constructor
    required this.destination,// Include this in constructor
  });

  // Factory method to create PlaceInfo from JSON
  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
    // Hardcode best months based on destinationName or some logic
    List<int> bestMonthsForPlace(String destinationName) {
      switch (destinationName) {
        case 'Taal View':
          return [11, 12, 1, 2]; // November to February
        case 'Cloud 9':
          return [6, 7, 8]; // June to August
        case 'Burnham Park':
          return [3, 4, 5]; // March to May
        case 'Hinulugang Taktak':
          return [12, 1, 2, 3, 4, 5]; // December to May
        case 'Vigan Heritage Village':
          return [11, 12, 1, 2, 3, 4]; // November to April
        default:
          return [1, 2, 3]; // Default best months (January to March)
      }
    }

    return PlaceInfo(
      city: json['city'],
      destinationName: json['destinationName'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      description: json['description'],
      destinationType: json['destinationType'] ?? 'local',
      image: json['image'] ?? 'assets/default_image.jpg',  // Provide a default image path if null
      bestMonths: bestMonthsForPlace(json['destinationName']), // Assign bestMonths based on place
      destination: json['destination'] ?? 'Unknown Destination', // Provide a default value
    );
  }
}

// Function to fetch places from the API
Future<List<PlaceInfo>> fetchDestinations() async {
  final response = await http.get(Uri.parse('http://localhost:3000/api/places'));

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
