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
  List<dynamic> mostSearchedCategories =
      []; // To store most searched categories
  List<dynamic> _touristSpots = [];
  List<dynamic> _filteredTouristSpots = []; // Filtered list to display
  final List<String> _imageUrls = [];
  final Map<String, List<dynamic>> _cachedResults = {};
  Timer? _debounce;
  bool isSearching = false;
  String searchQuery = '';
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
    fetchMostSearchedCategories();
    _fetchDestinations();
  }

  // Fetches destinations and initializes both lists
  void _fetchDestinations() async {
    List<dynamic> fetchedSpots = await fetchDestinations();
    setState(() {
      _touristSpots = fetchedSpots;
      _filteredTouristSpots =
          List.from(fetchedSpots); // Initially, show all spots
    });
  }

  // Handles search query input
  void _search(String query) {
    setState(() {
      searchQuery = query;
    });
    _searchForSpots(query);
  }

  Future<List<PlaceInfo>> fetchDestinations() async {
    try {
      final response = await http.get(
          Uri.parse('https://travication-backend.onrender.com/api/places'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<PlaceInfo> places = [];

        for (var item in data) {
          String city = item['city'] ?? 'Unknown City';
          String destinationName =
              item['destinationName'] ?? 'Unknown Destination';
          double latitude = item['latitude']?.toDouble() ?? 0.0;
          double longitude = item['longitude']?.toDouble() ?? 0.0;
          String description = item['description'] ?? 'No Description';
          String? destination = item['destination'];

          // Correctly format the image URL
          String dbImagePath = item['image']; // From the database
//String imageUrl = 'https://travication-backend.onrender.com/${dbImagePath.replaceAll('\\', '/')}';  // Replace Windows-style backslashes

          if (dbImagePath != null && dbImagePath.isNotEmpty) {
            // Construct the correct image URL
            String imageUrl =
                'http://localhost:4000/' + dbImagePath.replaceAll('\\', '/');
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
                destination: destination ?? 'Unknown Destination'));
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
      if (DateTime.now().difference(_lastActivityTime) >=
          _sessionTimeoutLimit) {
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

  void _searchForSpots(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (query.isNotEmpty) {
          _filteredTouristSpots = _touristSpots.where((spot) {
            final city = (spot['city'] ?? '').toLowerCase();
            return city.contains(query.toLowerCase());
          }).toList();
        } else {
          // Show all tourist spots if no query is entered
          _filteredTouristSpots = List.from(_touristSpots);
        }
      });
    });
  }

  Future<void> logSearch(String searchTerm) async {
    final response = await http.post(
      Uri.parse('https://travication-backend.onrender.com/logSearch'),
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
      Uri.parse(
          'https://travication-backend.onrender.com/logSearch'), // Update this to your API URL
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
    final response = await http.get(
        Uri.parse('https://travication-backend.onrender.com/mostSearched'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => {
                'title': item['title'],
                'image': item['image'],
              })
          .toList();
    } else {
      throw Exception('Failed to load most searched categories');
    }
  }

  void _searchtouristSpots(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (query.isNotEmpty) {
          _filteredTouristSpots = _touristSpots.where((spot) {
            final destinationName =
                spot['destinationName']?.toLowerCase() ?? '';
            final cityName = spot['city']?.toLowerCase() ?? '';
            return destinationName.contains(query.toLowerCase()) ||
                cityName.contains(query.toLowerCase());
          }).toList();
        } else {
          _filteredTouristSpots = List.from(_touristSpots);
        }
      });
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
              "Popular Tourist Spots",
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 0, 0, 0)),
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
                          city, // City name
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display the destinations for the city in a horizontal scroll view
                      SizedBox(
                        height:
                            350, // Set a fixed height for the horizontal scroll area
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: cityDestinations.map((place) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailScreen(spot: place),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 280, // Width of each image card
                                  margin: const EdgeInsets.only(
                                      right: 16), // Space between cards
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(12)),
                                            child: place.image != null &&
                                                    place.image!.isNotEmpty
                                                ? Image.network(
                                                    place.image!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      print(
                                                          'Error loading image: $error');
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                place.destinationName,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(place.city,
                                                  style: const TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const Divider(height: 40), // Divider between cities
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Bookmark()));
                  }),
                  _buildNavIcon(Icons.map, "Map", () {
                    // Define default latitude and longitude values
                    double defaultLat = 14.5995; // Example latitude (Manila)
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ItineraryPlannerPage()));
                  }),
                  _buildNavIcon(Icons.account_circle, "Account", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileAccountPage()));
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
                //_buildSearchSection(),
                const SizedBox(height: 20),
                _buildMainContent(context), // Call the renamed function here
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildNavIcon(
      IconData icon, String label, VoidCallback onTap) {
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

  Widget _buildTouristSpotsList() {
    return ListView.builder(
      itemCount: _filteredTouristSpots.length,
      itemBuilder: (context, index) {
        final spot = _filteredTouristSpots[index];
        final destinationName =
            spot['destinationName'] ?? 'Unknown Destination';
        final city = spot['city'] ?? 'Unknown City';
        final description = spot['description'] ?? 'No Description';
        final latitude = spot['latitude']?.toDouble() ?? 0.0;
        final longitude = spot['longitude']?.toDouble() ?? 0.0;

        return ListTile(
          title: Text(destinationName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("City: $city"),
              Text("Description: $description"),
              Text("Coordinates: ($latitude, $longitude)"),
            ],
          ),
        );
      },
    );
  }

  // Builds the search section widget
  /*Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text(
            "Explore New Places",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 15),
          Material(
            borderRadius: BorderRadius.circular(50),
            elevation: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: _search,
                        decoration: const InputDecoration(
                          hintText: "Enter a destination",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
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

@override
Widget _build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Tourist Spots"),
      backgroundColor: Colors.orange,
    ),
    body: Column(
      children: [
        _buildSearchSection(), 
        Expanded(
          child: _buildTouristSpotsList(),
        ),
      ],
    ),
  );
}*/

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
                  color: Colors.black
                      .withOpacity(0.1), // Adjusted shadow transparency
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
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
