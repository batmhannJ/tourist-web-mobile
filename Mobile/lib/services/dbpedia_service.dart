import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// DBpediaService class
class DBpediaService {
   final String proxyServerUrl = 'http://localhost:3000/proxy-image?url=';
 Future<List<dynamic>> fetchTouristSpots(String query) async {
    try {
      const String sparqlQuery = '''
      PREFIX dbo: <http://dbpedia.org/ontology/>
      PREFIX dbr: <http://dbpedia.org/resource/>
      PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>

      SELECT DISTINCT ?place ?placeLabel ?abstract ?thumbnail ?lat ?long
      WHERE {
        ?place dbo:country dbr:Philippines ;
               geo:lat ?lat ;
               geo:long ?long .

        OPTIONAL {
          ?place dbo:thumbnail ?thumbnail . 
        }

        OPTIONAL {
          ?place dbo:abstract ?abstract . 
          FILTER (lang(?abstract) = "en") 
        }

        ?place rdfs:label ?placeLabel . 
        FILTER (lang(?placeLabel) = "en") 
      }
      LIMIT 100000
      ''';

      final encodedQuery = Uri.encodeComponent(sparqlQuery);
      final url = 'http://dbpedia.org/sparql?query=$encodedQuery';
      print("Requesting URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse == null || jsonResponse['results'] == null || jsonResponse['results']['bindings'] == null) {
          print("No valid results found in response.");
          return [];
        }

        final List<dynamic> results = jsonResponse['results']['bindings'];
        if (results.isEmpty) {
          print("No bindings found in results.");
          return [];
        }

        List<dynamic> touristSpots = results.map((result) {
          String? imageUrl = result['thumbnail']?['value'];
          String placeName = result['placeLabel']['value'];

          // Use the proxy URL to fetch the image
          String proxyImageUrl = imageUrl != null ? '$proxyServerUrl$imageUrl' : 'No image available';

          return {
            'place': result['place']['value'],
            'name': placeName,
            'description': result['abstract']?['value'] ?? 'No description available',
            'imageUrl': proxyImageUrl,
            'lat': result['lat']['value'],
            'long': result['long']['value'],
          };
        }).toList();

        return touristSpots;
      } else {
        print("Error response: ${response.body}");
        throw Exception("Failed to load tourist spots");
      }
    } catch (e) {
      print("Error during fetching: $e");
      return [];
    }
  }
}