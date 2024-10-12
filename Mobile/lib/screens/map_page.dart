import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

//void main() => runApp(const MapPage());

class MapPage extends StatefulWidget {
  
  final double destinationLat; // Latitude of the destination
  final double destinationLong; // Longitude of the destination

  const MapPage({Key? key, required this.destinationLat, required this.destinationLong}) : super(key: key);

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
  final Set<Polyline> _polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = []; // Store your decoded polyline coordinates here


  String routeId = '';
  String sectionId = '';
  String type = '';
  String departureTime = '';
  String departureLocation = '';
  String arrivalTime = '';
  String arrivalLocation = '';


  @override
  void initState() {
    super.initState();
    _determinePosition();    // Fetch weather data for the map center
    fetchRoute(); // Tawagin ang fetchRoute dito
    _getWeatherAtCenter();
  }

Future<void> fetchRoute() async {
  if (_userLocation == null) {
    print('User location is not available');
    return;
  }

  final double startLat = _userLocation!.latitude;
  final double startLon = _userLocation!.longitude;
  final double endLat = widget.destinationLat;
  final double endLon = widget.destinationLong;

  const String apiKey = 'W8rx2Ay1muHkc3LL5ZRMOuzACoINfI5Jzav8sGKV8o4'; // Your HERE API key
  final String url = 'https://router.hereapi.com/v8/routes?origin=$startLat,$startLon&destination=$endLat,$endLon&transportMode=car&return=polyline,summary,actions&apiKey=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Print the entire response to inspect its structure
      print('API Response: $data');
      processRoute(data);

      if (data['routes'].isEmpty || data['routes'][0]['sections'].isEmpty) {
        setState(() {
          _showNoRouteFoundDialog(); // Display the dialog if no route found
        });
      }

if (data['routes'].isNotEmpty && data['routes'][0]['sections'].isNotEmpty) {
  final String encodedPolyline = data['routes'][0]['sections'][0]['polyline'];
  
  // Debugging: Check polyline response
  print('Encoded Polyline: $encodedPolyline');
  
  if (encodedPolyline.isNotEmpty) {
  List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline); // flutter_polyline_points decoding
  if (result.isNotEmpty) {
    displayRoute(result);
  } else {
    print('No points found in polyline.');
  }
}
 else {
    print('Encoded polyline is empty.');
  }
}
 else {
      print('No route found in response');
  }
    } else {
      print('Failed to load route: ${response.statusCode}');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Error fetching route: $e');
  }
}
void processRoute(Map<String, dynamic> response) {
    if (response['routes'] == null || response['routes'].isEmpty) {
      print("No routes found in the response.");
      return;
    }

    setState(() {
      final route = response['routes'][0];
      final section = route['sections'][0];

      routeId = route['id'];
      sectionId = section['id'];
      type = section['type'];
      departureTime = section['departure']['time'];
      departureLocation = 'lat=${section['departure']['place']['location']['lat']}, lng=${section['departure']['place']['location']['lng']}';
      arrivalTime = section['arrival']['time'];
      arrivalLocation = 'lat=${section['arrival']['place']['location']['lat']}, lng=${section['arrival']['place']['location']['lng']}';
    });
  }
  // Add this widget to display route and weather details below the map
  Widget _buildRouteDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          //Text('Route ID: $routeId'),
          //Text('Section ID: $sectionId'),
          Text('Type: $type'),
          Text('Departure Time: $departureTime'),
          Text('Departure Location: $departureLocation'),
          Text('Arrival Time: $arrivalTime'),
          Text('Arrival Location: $arrivalLocation'),
        ],
      ),
    );
  }
void _showNoRouteFoundDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('No Route Found'),
        content: const Text('Sorry, we could not calculate a route between your location and the destination. It cannot be traveled by vehicle.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// --- ADD DECODE POLYLINE FUNCTION HERE ---
 List<LatLng> decodePolyline(String encoded) {
  List<LatLng> polyline = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    polyline.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return polyline;
}
void displayRoute(List<PointLatLng> points) {
  // Map List<PointLatLng> to List<LatLng>
  List<LatLng> routeCoords = points
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList();

  print('Route Coordinates: $routeCoords');

  setState(() {
    polylineCoordinates = routeCoords; // Store the polyline coordinates

    // Add the polyline to the map
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('routes'), // Dynamically assigned ID
        points: routeCoords, // Use the mapped coordinates
        color: Colors.red,   // Customizable color
        width: 5,            // Customizable width
      ),
    );
  });
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
      // Add user location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );

      // Add destination marker
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destinationLat, widget.destinationLong),
          infoWindow: const InfoWindow(
            title: 'Destination',
            snippet: 'Your searched location',
          ),
        ),
      );

      // Move camera to show both user location and destination
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              widget.destinationLat < _userLocation!.latitude ? widget.destinationLat : _userLocation!.latitude,
              widget.destinationLong < _userLocation!.longitude ? widget.destinationLong : _userLocation!.longitude,
            ),
            northeast: LatLng(
              widget.destinationLat > _userLocation!.latitude ? widget.destinationLat : _userLocation!.latitude,
              widget.destinationLong > _userLocation!.longitude ? widget.destinationLong : _userLocation!.longitude,
            ),
          ),
          100, // padding
        ),
      );
      fetchRoute();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
              initialCameraPosition: const CameraPosition(target: LatLng(14.5995, 120.9842), zoom: 11.0), // Default view
              markers: Set<Marker>.of(_markers),
              polylines: _polylines,
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
                    _buildRouteDetails(), 
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