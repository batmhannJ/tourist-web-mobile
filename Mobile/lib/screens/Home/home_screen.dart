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
import 'widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/user_provider.dart';
import 'package:flutter_application_2/services/dbpedia_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:flutter_application_2/model/place_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  Timer? _sessionTimer;
  static const Duration _sessionTimeoutLimit = Duration(minutes: 2);
  DateTime _lastActivityTime = DateTime.now();
  List<dynamic> mostSearchedCategories = []; // To store most searched categories
  List<dynamic> _touristSpots = [];
  final List<String> _imageUrls = [];
  final Map<String, List<dynamic>> _cachedResults = {};
  Timer? _debounce;
   bool isSearching = false;
  String searchQuery = '';
  String? imagePath;
  // Function to handle search
  void _search(String query) {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty; // Set isSearching to true if there's a query
    });
  }
  
  @override
  void initState() {
    super.initState();
    _startSessionTimer();
    fetchMostSearchedCategories(); 
    fetchDestinations(); 
  }

Future<List<PlaceInfo>> fetchDestinations() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/api/places'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<PlaceInfo> places = [];

      for (var item in data) {
        String city = item['city'] ?? 'Unknown City';
        String destinationName = item['destinationName'] ?? 'Unknown Destination';
        double latitude = item['latitude']?.toDouble() ?? 0.0;
        double longitude = item['longitude']?.toDouble() ?? 0.0;
        String description = item['description'] ?? 'No Description';
        String? destination = item['destination'];

        // Correctly format the image URL
String dbImagePath = item['image']; // From the database
//String imageUrl = 'http://localhost:3000/${dbImagePath.replaceAll('\\', '/')}';  // Replace Windows-style backslashes

      if (dbImagePath != null && dbImagePath.isNotEmpty) {
      // Construct the correct image URL
      String imageUrl = 'http://localhost:4000/' + dbImagePath.replaceAll('\\', '/');
        print('Image URL: $imageUrl');

        places.add(PlaceInfo(
          city: city,
          destinationName: destinationName,
          latitude: latitude,
          longitude: longitude,
          description: description,
          destinationType: item['destinationType'] ?? 'local',
          image: imageUrl,
          bestMonths: bestMonthsForPlace(destinationName),
          destination: destination ?? 'Unknown Destination'
        ));
      }
      }
      return places;
    } else {
      throw Exception('Failed to load places');
    }
  } catch (error) {
    print('Error fetching destinations: $error');
    return [];
  }
}



 List<int> bestMonthsForPlace(String destinationName) {
    // Your logic to determine the best months for the given destination
    // Example implementation:
    switch (destinationName.toLowerCase()) {
      case 'Baguio':
        return [5, 6, 7, 8]; // Example months for Paris
      case 'Bohol':
        return [3, 4, 5, 10, 11]; // Example months for Tokyo
      // Add more cases as needed
      default:
        return []; // Return empty if no specific months are defined
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (DateTime.now().difference(_lastActivityTime) >= _sessionTimeoutLimit) {
        _handleSessionExpired();
      }
    });
  }

  void _handleSessionExpired() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login_page');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
    });
  }

  void _updateActivityTime() {
    setState(() {
      _lastActivityTime = DateTime.now();
    });
  }
  

 final Map<String, String?> imageCache = {};


void _searchForSpots(String query) async {
  if (_cachedResults.containsKey(query)) {
    setState(() {
      _touristSpots = _cachedResults[query]!;
    });
    return;
  }

  try {
    final service = DBpediaService();

    // Log the search term before fetching results
    await logSearch(query);  // Call the logSearch function here
    
    // Fetching tourist spots with image URLs
    final allSpots = await service.fetchTouristSpots(query);

    // Filtering spots based on the query
    final filteredSpots = allSpots.where((spot) {
      return (spot['name']?.toLowerCase() ?? "").contains(query.toLowerCase());
    }).toList();

    setState(() {
      _touristSpots = filteredSpots;
      _cachedResults[query] = filteredSpots;
    });
        // Optionally, update the most searched categories here
    await updateMostSearchedCategories(query);
  } catch (e) {
    print('Error searching for spots: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error searching for spots: $e')),
    );
  }
}

Future<void> logSearch(String searchTerm) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/logSearch'),
    body: {'searchTerm': searchTerm},
  );

  if (response.statusCode == 200) {
    print('Search term logged successfully.');
  } else {
    print('Failed to log search term: ${response.reasonPhrase}');
  }
}

Future<void> updateMostSearchedCategories(String query) async {
  final response = await http.post(
    Uri.parse('http://localhost:3000/logSearch'),  // Update this to your API URL
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'searchTerm': query}),
  );

  if (response.statusCode == 200) {
    print('Search term updated successfully.');
  } else {
    print('Failed to update search term: ${response.reasonPhrase}');
  }
}

Future<List<dynamic>> fetchMostSearchedCategories() async {
  final response = await http.get(Uri.parse('http://localhost:3000/mostSearched'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => {
      'title': item['title'],
      'image': item['image'],
    }).toList();
  } else {
    throw Exception('Failed to load most searched categories');
  }
}

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(seconds: 3), () {
    _searchForSpots(query);  // Call the updated function
  });
}

// Build the main content
Widget _buildMainContent(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Most Search Destinations", 
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
        const SizedBox(height: 16),
        _buildCategorySection(), // Preserved function

        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Popular Tourist Spots", 
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
        const SizedBox(height: 16),

        const SizedBox(height: 24),

        // Fetch and display destinations using FutureBuilder
        FutureBuilder<List<PlaceInfo>>(
          future: fetchDestinations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No destinations found.'));
            }

            List<PlaceInfo> destinations = snapshot.data!;

            // Group destinations by city
            Map<String, List<PlaceInfo>> destinationsByCity = {};
            for (var place in destinations) {
              destinationsByCity.putIfAbsent(place.city, () => []).add(place);
            }

            return Column(
              children: destinationsByCity.entries.map((entry) {
                String city = entry.key;
                List<PlaceInfo> cityDestinations = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        city,  // City name
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display the destinations for the city
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: cityDestinations.length,
                      itemBuilder: (context, index) {
                        PlaceInfo place = cityDestinations[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(spot: place),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: place.image != null && place.image!.isNotEmpty
                                        ? Image.network(
                                            place.image!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading image: $error');
                                              return Image.asset(
                                                'assets/images/tagtay.jpg',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/images/tagtay.jpg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.destinationName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(place.city, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 40),  // Divider between cities
                  ],
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}


  @override
Widget build(BuildContext context) {
  // Retrieve user name from UserProvider
  final userName = Provider.of<UserProvider>(context).user.name;

  return GestureDetector(
    onPanUpdate: (_) => _updateActivityTime(),
    onTap: () => _updateActivityTime(),
    onPanEnd: (_) => _updateActivityTime(),
    child: Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavIcon(Icons.home, "Home", () {}),
                _buildNavIcon(Icons.bookmark, "Calendar", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Bookmark()));
                }),
                _buildNavIcon(Icons.map, "Map", () {
                  // Define default latitude and longitude values
                  double defaultLat = 14.5995;  // Example latitude (Manila)
                  double defaultLong = 120.9842; // Example longitude (Manila)

                  // Navigate to MapPage and pass the latitude and longitude
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(
                        destinationLat: defaultLat,
                        destinationLong: defaultLong,
                      ),
                    ),
                  );
                }),
                _buildNavIcon(Icons.event_note, "Planner", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ItineraryPlannerPage()));
                }),
                _buildNavIcon(Icons.account_circle, "Account", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileAccountPage()));
                }),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAppBar(userName),
              const SizedBox(height: 20),
              _buildSearchSection(),
              const SizedBox(height: 20),
              _buildMainContent(context),  // Call the renamed function here
            ],
          ),
        ),
      ),
    ),
  );
}

  GestureDetector _buildNavIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: kPrimaryClr),
          Text(label),
        ],
      ),
    );
  }

// Helper method to build the app bar
Widget _buildAppBar(String userName) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Colors.orange, Color.fromARGB(255, 255, 230, 0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage("assets/images/welcome.jpeg"),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Arial',
                letterSpacing: 0.8,
              ),
            ),
            Text(
              userName.isNotEmpty ? userName : "Guest",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
        const Spacer(),
        const Icon(
          Icons.notifications,
          color: Colors.white,
          size: 28,
        ),
      ],
    ),
  );
}

 Widget _buildSearchSection() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.orange, // Changed to teal for a more fresh look
      borderRadius: BorderRadius.circular(10), // Slightly less rounded corners
    ),
    padding: const EdgeInsets.all(12), // Padding is reduced for a more compact design
    child: Column(
      children: [
        const Text(
          "Explore New Places",
          style: TextStyle(
            fontSize: 28, // Larger font size for emphasis
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Material(
          borderRadius: BorderRadius.circular(50), // Keeping the rounded shape
          elevation: 6, // A bit higher elevation for better shadow effect
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1), // Adding a border
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: _onSearchChanged, // Functionality remains unchanged
                      decoration: const InputDecoration(
                        hintText: "Enter a destination",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color.fromARGB(255, 218, 164, 17),
                    child: Icon(Icons.sort_by_alpha_sharp, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


 Widget _buildCategorySection() {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 10),
    child: FutureBuilder<List<dynamic>>(
      future: fetchMostSearchedCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories available.'));
        }

        final categories = snapshot.data!;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),  // Adjusted shadow transparency
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,  // Enable horizontal scrolling
            child: Row(
              children: List.generate(categories.length, (index) {
                final category = categories[index];
                return CategoryCard(
                  press: () {
                    print('Selected: ${category['title']}');
                  },
                  image: category['image'],
                  title: category['title'],
                );
              }),
            ),
          ),
        );
      },
    ),
  );
}
}
