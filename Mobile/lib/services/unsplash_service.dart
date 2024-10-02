import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  static const String accessKey = 'QeRYMS6szXkLjkCpYacdR7gA2N5Tvgxiw6CF4cMgG8c'; // Replace with your actual key
  static const String baseUrl = 'https://api.unsplash.com/search/photos';

  Future<List<String>> searchImages(String query) async {
    if (query.isEmpty) {
      throw Exception('Query cannot be empty');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?query=$query&client_id=$accessKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> imageUrls = (data['results'] as List).map((result) {
          return result['urls']['regular'] as String; // Get the regular-sized image URL
        }).toList();

        return imageUrls;
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }
}
