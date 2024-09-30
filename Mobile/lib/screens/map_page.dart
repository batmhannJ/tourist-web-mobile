import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MapPage());

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MyAppState();
}

class _MyAppState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(14.5995, 120.9842); // Manila, Philippines
  final List<Marker> _markers = [];
  final String openWeatherApiKey = '2bc98ff38408a672a88464642be09e6f'; // Replace with your OpenWeather API key
  String weatherInfo = ''; // Store weather info for display
  LatLng? _userLocation; // To store the user's current location

  @override
  void initState() {
    super.initState();
    _determinePosition();    // Fetch weather data for the map center
  }


 // Function to request location permission and get the user's current location
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Request permission for location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    // Get the current location of the user
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);

      // Add marker for user's location
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: _userLocation!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'This is where you are.',
          ),
        ),
      );
    });

    // Move the camera to the user's location
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_userLocation!, 14),
    );

    // Fetch weather for user's location
    _getWeatherAtLocation(_userLocation!);
  }

  // Fetch weather data at user's location
  Future<void> _getWeatherAtLocation(LatLng location) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&appid=$openWeatherApiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temperature = data['main']['temp'];
        final weatherDescription = data['weather'][0]['description'];
        setState(() {
          weatherInfo = 'Temp: $temperature°C, $weatherDescription';
        });
      } else {
        print('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }
  // Fetch markers from your backend server
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

  // Fetch weather data at the map's center (_center LatLng)
  Future<void> _getWeatherAtCenter() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${_center.latitude}&lon=${_center.longitude}&appid=$openWeatherApiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temperature = data['main']['temp'];
        final weatherDescription = data['weather'][0]['description'];
        setState(() {
          weatherInfo = 'Temp: $temperature°C, $weatherDescription';
        });
      } else {
        print('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
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
          title: const Text('Maps with Weather and Markers'),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: [
            // Google Map widget
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: Set<Marker>.of(_markers),
            ),
            // Display weather information on top of the map
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weather at Center:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(weatherInfo), // Display weather data
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}