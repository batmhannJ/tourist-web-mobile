import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';
import 'package:flutter_application_2/screens/detailscreen/detail_screen.dart';
import 'dart:async'; 

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
 // Function to filter tourist spots based on selected month
Widget _buildTouristSpotsByMonth() {
  if (_selectedMonth == null) {
    return const SizedBox();
  }

  // Get the numeric month for filtering
  int selectedMonthIndex = months.indexOf(_selectedMonth!) + 1;
  print("Selected month index: $selectedMonthIndex");  // Debug log

  // Filter logic to show all destinations with the city 'Baguio' when January is selected
  List<PlaceInfo> filteredPlaces = places.where((place) {
    // Check if the place's bestMonths list contains the selected month
    return place.bestMonths.contains(selectedMonthIndex);
  }).toList();

  if (filteredPlaces.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text("No tourist spots found for this month."),
    );
  }

  // Display the filtered places
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: filteredPlaces.length,
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(left: 5, right: 15),
        child: ListTile(
          title: Text(filteredPlaces[index].destinationName),
          subtitle: Text(filteredPlaces[index].city),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  spot: filteredPlaces[index],
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
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text("Select a Month", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildMonthGrid(),
          const SizedBox(height: 20),
          if (_selectedMonth != null) _buildTouristSpotsByMonth(),
        ],
      ),
    );
  }
}
