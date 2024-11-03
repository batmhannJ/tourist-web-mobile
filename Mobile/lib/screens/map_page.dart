import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  final double destinationLat;
  final double destinationLong;

  const MapPage({
    Key? key,
    required this.destinationLat,
    required this.destinationLong,
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  final List<Marker> _markers = [];
  LatLng? _userLocation;
  final Set<Polyline> _polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints();

  String distance = '';
  String duration = '';
  String summary = '';

  @override
  void initState() {
    super.initState();
    _determinePosition();
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

    final String url =
        'https://travication-backend.onrender.com/directions?origin=$startLat,$startLon&destination=$endLat,$endLon';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final legs = route['legs'][0];

          setState(() {
            distance = legs['distance']['text'];
            duration = legs['duration']['text'];
            summary = route['summary'];
          });

          final String encodedPolyline = route['overview_polyline']['points'];
          if (encodedPolyline.isNotEmpty) {
            List<PointLatLng> result =
                polylinePoints.decodePolyline(encodedPolyline);
            if (result.isNotEmpty) {
              displayRoute(result);
            }
          }
        } else {
          print('No routes found in the response.');
        }
      } else {
        print('Failed to load route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  void displayRoute(List<PointLatLng> points) {
    if (points.isEmpty) return;

    List<LatLng> routePoints =
        points.map((point) => LatLng(point.latitude, point.longitude)).toList();

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);

        _markers.add(Marker(
          markerId: const MarkerId('userLocation'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
        ));

        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destinationLat, widget.destinationLong),
          infoWindow: const InfoWindow(title: 'Destination'),
        ));
      });

      _moveCameraToBounds();
      fetchRoute();
    } catch (e) {
      print('Error determining position: $e');
    }
  }

  void _moveCameraToBounds() {
    if (mapController == null || _userLocation == null) return;

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            widget.destinationLat < _userLocation!.latitude
                ? widget.destinationLat
                : _userLocation!.latitude,
            widget.destinationLong < _userLocation!.longitude
                ? widget.destinationLong
                : _userLocation!.longitude,
          ),
          northeast: LatLng(
            widget.destinationLat > _userLocation!.latitude
                ? widget.destinationLat
                : _userLocation!.latitude,
            widget.destinationLong > _userLocation!.longitude
                ? widget.destinationLong
                : _userLocation!.longitude,
          ),
        ),
        100,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Route'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Distance: $distance'),
                Text('Duration: $duration'),
                Text('Route Summary: $summary'),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(14.5995, 120.9842),
                zoom: 7,
              ),
              markers: Set<Marker>.of(_markers),
              polylines: _polylines,
            ),
          ),
        ],
      ),
    );
  }
}
