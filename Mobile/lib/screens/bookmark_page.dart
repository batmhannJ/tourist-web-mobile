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
import 'package:intl/intl.dart'; // Import for DateFormat

class Bookmark extends StatefulWidget {
  const Bookmark({Key? key}) : super(key: key);

  @override
  State<Bookmark> createState() => _Bookmark();
}

class _Bookmark extends State<Bookmark> {
  List<PlaceInfo> places = [];  // Store PlaceInfo objects
  String? _selectedMonth;
  int? _selectedDay; // Track selected day

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
      setState(() {
        places = fetchedPlaces;  // Update the state with fetched places
      });
    } catch (error) {
      print('Error fetching places: $error');
    }
  }

  Widget _buildMonthGrid() {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, // Number of columns
      childAspectRatio: 1.2, // Aspect ratio for cards
    ),
    itemCount: months.length,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedMonth = months[index]; // Update the selected month
          });
          _showDaysPopup(); // Show the days popup
        },
        child: Container(
          margin: const EdgeInsets.all(10), // Space between cards
          decoration: BoxDecoration(
            color: _selectedMonth == months[index] ? Colors.blueAccent : Colors.white, // Change color based on selection
            borderRadius: BorderRadius.circular(12), // Rounded corners
            border: Border.all(
              color: _selectedMonth == months[index] ? Colors.blue : Colors.grey.shade300, // Border color change
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4), // Shadow position
              ),
            ],
          ),
          child: Center(
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _selectedMonth == months[index] ? Colors.white : Colors.black, // Text color change
              ),
            ),
          ),
        ),
      );
    },
  );
}

 void _showDaysPopup() {
  int daysInMonth = DateTime(DateTime.now().year, months.indexOf(_selectedMonth!) + 2, 0).day;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // No rounded corners
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10), // Padding around the dialog
          width: 320, // Dialog width
          height: 400, // Dialog height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the content
            children: [
              Text(
                _selectedMonth!.toUpperCase(), // Month in uppercase
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  color: Color(0xFF2C3E50), // Dark slate color
                ),
                textAlign: TextAlign.center, // Centered text
              ),
              const SizedBox(height: 8), // Space between title and line
              Divider( // Divider line
                color: Colors.grey.shade400, // Line color
                thickness: 1, // Line thickness
              ),
              const SizedBox(height: 8), // Space between line and grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7 columns for days
                    childAspectRatio: 1, // Square tiles
                    crossAxisSpacing: 8, // Space between columns
                    mainAxisSpacing: 8, // Space between rows
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, dayIndex) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = dayIndex + 1; // Update selected day
                        });
                        Navigator.of(context).pop(); // Close the dialog
                        _showTouristSpots(); // Show tourist spots for the selected day
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (_selectedDay != null && _selectedDay == dayIndex + 1)
                              ? const Color(0xFF4A90E2) // A softer blue for selected
                              : const Color(0xFFF2F2F2), // Light grey for unselected
                          borderRadius: BorderRadius.zero, // No rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          (dayIndex + 1).toString(), // Day number without bold
                          style: const TextStyle(
                            color: Color(0xFF2C3E50), // Dark slate color
                            fontSize: 20,
                            // Removed bold style
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18), // Text size for the button
                  ),
                  child: const Text('Cancel'), // Cancel button
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showTouristSpots() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      List<PlaceInfo> filteredPlaces = places.where((place) {
        return place.bestMonths.contains(months.indexOf(_selectedMonth!) + 1);
      }).toList();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // No rounded corners
        backgroundColor: Colors.white,
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          height: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the text
            children: [
              Text(
                'BEST TOURIST SPOTS',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF2C3E50), // Dark slate color for the title
                ),
                textAlign: TextAlign.center, // Center the title
              ),
              const SizedBox(height: 5),
              Text(
                '${_selectedMonth} ${_selectedDay}', // Smaller text for the date
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey, // Grey color for the date
                ),
                textAlign: TextAlign.center, // Center the date
              ),
              const SizedBox(height: 10), // Space before the line
              Divider( // Divider line
                color: Colors.grey.shade400,
                thickness: 1,
              ),
              const SizedBox(height: 10), // Space after the line
              Expanded(
                child: filteredPlaces.isEmpty
                    ? const Center(child: Text("No tourist spots found for this date.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: filteredPlaces.length,
                        itemBuilder: (context, index) {
                          String? dbImagePath = filteredPlaces[index].image;
                          String imageUrl = (dbImagePath != null && dbImagePath.isNotEmpty)
                              ? 'http://localhost:4000/' + dbImagePath.replaceAll('\\', '/')
                              : 'assets/images/tagtay.jpg'; // Default image URL

                          return GestureDetector(
                            onTap: () {
                              PlaceInfo selectedSpot = filteredPlaces[index];
                              selectedSpot.image = imageUrl; // Assigning imageUrl to the spot's image property
                              // Navigate to DetailScreen on tap
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                  spot: selectedSpot,  // Pass the updated PlaceInfo object
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: 80,
                                        height: 80,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('Error loading image: $error');
                                          return Image.asset(
                                            'assets/images/default_image.png',
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            filteredPlaces[index].destinationName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C3E50)), // Match the font style
                                          ),
                                          Text(
                                            filteredPlaces[index].city,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Close', style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ),
            ],
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
      body: SingleChildScrollView( // Wrap Column with SingleChildScrollView
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text("Tourist Calendar", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMonthGrid(),
          ],
        ),
      ),
    );
  }
}

