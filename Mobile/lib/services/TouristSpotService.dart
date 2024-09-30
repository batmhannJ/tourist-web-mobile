import 'dart:convert';
import 'package:http/http.dart' as http;

class TouristSpotService {
  final String apiKey = '5ae2e3f221c38a28845f05b6f4b00254f1536d7f289b64336ca0fe7f';

    Future<List<dynamic>> searchTouristSpots(String query) async {
    final String url =
        'https://api.opentripmap.com/0.1/en/places/geoname?name=$query&apikey=$apiKey';

    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Log the response body

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Create a list with the data you need
      return [
        {
          'name': data['name'],
          'country': data['country'],
          'lat': data['lat'],
          'lon': data['lon'],
        }
      ]; // Return a list with one item
    } else {
      throw Exception('Failed to load tourist spots');
    }
  }

}
