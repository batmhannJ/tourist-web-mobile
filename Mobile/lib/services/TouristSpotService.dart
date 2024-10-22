import 'dart:convert';
import 'package:http/http.dart' as http;

class TouristSpotService {
  final String baseUrl = 'http://localhost:4000'; // Your backend API URL

  // Fetch tourist spots from your database based on the search query
  Future<List<dynamic>> searchTouristSpots(String query) async {
    // Make an API call to your backend server to search tourist spots from the database
    final String url = '$baseUrl/searchTouristSpots?query=$query';

    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Log the response body

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body); // Expecting an array of tourist spots

      // Return the list of tourist spots with their name, country, imageUrl, lat, and lon
      return data.map((spot) => {
        'destinationName': spot['destinationName'],
        'city': spot['city'],
        'image': spot['image'] ?? 'assets/images/tagtay.jpg',
        'latitude': spot['latitude'],
        'longitude': spot['longitude'],
      }).toList();
    } else {
      throw Exception('Failed to load tourist spots');
    }
  }
}
