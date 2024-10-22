import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';
import 'package:flutter_application_2/screens/detailscreen/detail_screen.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/services/dbpedia_service.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({Key? key}) : super(key: key);

  @override
  State<Bookmark> createState() => _Bookmark();
}

class _Bookmark extends State<Bookmark> {
  List<PlaceInfo> places = [];
  String? _selectedMonth;

  List<String> months = [
    "January", "February", "March", "April", "May", "June", 
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    try {
      List<PlaceInfo> fetchedPlaces = await fetchDestinations();
      setState(() {
        places = fetchedPlaces;
      });
    } catch (error) {
      print('Error fetching places: $error');
    }
  }

  Widget _buildTouristSpotsByMonth() {
    if (_selectedMonth == null) {
      return const SizedBox();
    }

    int selectedMonthIndex = months.indexOf(_selectedMonth!) + 1;
    List<PlaceInfo> filteredPlaces = places.where((place) {
      return place.bestMonths.contains(selectedMonthIndex);
    }).toList();

    if (filteredPlaces.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No tourist spots found for this month.", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPlaces.length,
      itemBuilder: (context, index) {
        String? dbImagePath = filteredPlaces[index].image;
        String imageUrl = (dbImagePath != null && dbImagePath.isNotEmpty) 
            ? 'http://localhost:4000/' + dbImagePath.replaceAll('\\', '/') 
            : 'assets/images/tagtay.jpg';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8.0),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/default_image.png',
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    );
                  },
                ),
              ),
              title: Text(
                filteredPlaces[index].destinationName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filteredPlaces[index].city,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              onTap: () {
                PlaceInfo selectedSpot = filteredPlaces[index];
                selectedSpot.image = imageUrl;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      spot: selectedSpot,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
      ),
      itemCount: months.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMonth = months[index];
            });
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue), // Add a calendar icon
                  const SizedBox(height: 8),
                  Text(months[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourist Spots by Month'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Select a Month",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildMonthGrid(),
            const SizedBox(height: 20),
            if (_selectedMonth != null) _buildTouristSpotsByMonth(),
          ],
        ),
      ),
    );
  }
}
