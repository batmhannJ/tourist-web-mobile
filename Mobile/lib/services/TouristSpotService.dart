import 'dart:convert';
import 'package:http/http.dart' as http;

class TouristSpotService {
  final String apiKey = '5ae2e3f221c38a28845f05b6f4b00254f1536d7f289b64336ca0fe7f';
  final String unsplashApiKey = 'QeRYMS6szXkLjkCpYacdR7gA2N5Tvgxiw6CF4cMgG8c';

  Future<List<dynamic>> searchTouristSpots(String query) async {
    final String url =
        'https://api.opentripmap.com/0.1/en/places/geoname?name=$query&apikey=$apiKey';

    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Log the response body

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String name = data['name'];
      String country = data['country'];

      String imageUrl = await _getImageFromUnsplash(name);

      return [
        {
          'name': name,
          'country': country,
          'imageUrl': imageUrl, 
          'lat': data['lat'],
          'lon': data['lon'],
        }
      ];
    } else {
      throw Exception('Failed to load tourist spots');
    }
  }

  Future<String> _getImageFromUnsplash(String spotName) async {
    final String unsplashUrl =
        'https://api.unsplash.com/search/photos?query=$spotName&client_id=$unsplashApiKey';

    final response = await http.get(Uri.parse(unsplashUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['urls']['regular'];
      }
    }

    return 'https://example.com/default_image.jpg';
  }
}
