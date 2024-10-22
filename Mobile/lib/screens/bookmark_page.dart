import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';
import 'package:flutter_application_2/screens/detailscreen/detail_screen.dart';
import 'package:flutter_application_2/screens/bookmark_page.dart';
import 'package:flutter_application_2/screens/map_page.dart';
import 'package:flutter_application_2/screens/itinerary_planner_page.dart';
import 'package:flutter_application_2/screens/profile_account.dart';
import 'package:flutter_application_2/utilities/colors.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'dart:async'; 
//import 'widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/user_provider.dart';
import 'package:flutter_application_2/services/dbpedia_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

class Bookmark extends StatefulWidget {
  const Bookmark({Key? key}) : super(key: key);

  @override
  State<Bookmark> createState() => _Bookmark();
}

class _Bookmark extends State<Bookmark> {
  List<PlaceInfo> places = [];  // Store PlaceInfo objects
  String? _selectedMonth;

  List<String> months = [
    "January", "February", "March", "April", "May", "June", "July", "August",
    "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();  // Fetch places when the widget is initialized
  }

  // Function to fetch places and update the state
  Future<void> _fetchPlaces() async {
    try {
      List<PlaceInfo> fetchedPlaces = await fetchDestinations();  // Fetch from API

      // Debugging: Print fetched places
      print("Fetched places: ${fetchedPlaces.length}");
      for (var place in fetchedPlaces) {
        print("Place: ${place.city}, Best Months: ${place.bestMonths}");
      }

      setState(() {
        places = fetchedPlaces;  // Update the state with fetched places
      });
    } catch (error) {
      print('Error fetching places: $error');
    }
  }

 // Function to filter tourist spots based on selected month
Widget _buildTouristSpotsByMonth() {
  if (_selectedMonth == null) {
    return const SizedBox();
  }

  // Get the numeric month for filtering
  int selectedMonthIndex = months.indexOf(_selectedMonth!) + 1;

  // Filter logic to show all destinations based on the selected month
  List<PlaceInfo> filteredPlaces = places.where((place) {
    return place.bestMonths.contains(selectedMonthIndex);
  }).toList();

  if (filteredPlaces.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text("No tourist spots found for this month."),
    );
  }

  // Display the filtered places with images
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: filteredPlaces.length,
    itemBuilder: (context, index) {
// Construct the image URL based on the provided logic
String? dbImagePath = filteredPlaces[index].image; // This is now nullable
String imageUrl = (dbImagePath != null && dbImagePath.isNotEmpty) 
    ? 'http://localhost:4000/' + dbImagePath.replaceAll('\\', '/') 
    : 'assets/images/tagtay.jpg'; // Provide a default image URL


      return Padding(
        padding: const EdgeInsets.only(left: 5, right: 15),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return Image.asset(
                  'assets/images/default_image.png', // Update to your default image path
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                );
              },
            ),
          ),
          title: Text(filteredPlaces[index].destinationName),
          subtitle: Text(filteredPlaces[index].city),
          onTap: () {
              // Update the image property of the spot
              PlaceInfo selectedSpot = filteredPlaces[index];
              selectedSpot.image = imageUrl; // Assigning imageUrl to the spot's image property

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    spot: selectedSpot,  // Pass the updated PlaceInfo object
                  ),
                ),
              );
            },
        ),
      );
    },
  );
}

  // Build the grid for selecting months
  Widget _buildMonthGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2,
      ),
      itemCount: months.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMonth = months[index];  // Update the selected month
            });
          },
          child: Card(
            child: Center(child: Text(months[index])),
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
      body: SingleChildScrollView( // Wrap Column with SingleChildScrollView
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Select a Month", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
