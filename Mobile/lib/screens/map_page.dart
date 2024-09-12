import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MapPage());

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MyAppState();
}

class _MyAppState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(12, 34);
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _fetchMarkersFromServer();  // Fetch markers from your backend server
  }

  Future<void> _fetchMarkersFromServer() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/markers'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _markers.clear();
          for (var item in data) {
            final LatLng latLng = LatLng(
              item['latitude'],
              item['longitude'],
            );
            _markers.add(
              Marker(
                markerId: MarkerId(item['_id']),
                position: latLng,
                infoWindow: InfoWindow(
                  title: item['destinationName'], // Add a title to the marker's info window
                  snippet: item['description'], // Add a description or snippet
                ),
              ),
            );
          }
        });
      } else {
        print('Failed to load markers');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps with Backend Markers'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: Set<Marker>.of(_markers),
        ),
      ),
    );
  }
}
