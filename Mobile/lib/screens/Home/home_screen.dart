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

  // Function to handle search
  void _search(String query) {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty; // Set isSearching to true if there's a query
    });
  }

  List<String> months = [
    "January", "February", "March", "April", "May", "June", "July", "August",
    "September", "October", "November", "December"
  ];
  List<dynamic> touristSpots = [];

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
    fetchTouristSpots();
    fetchMostSearchedCategories(); 
    fetchDestinations();
  }

  void fetchTouristSpots() async {
    DBpediaService dbpediaService = DBpediaService();
    List<dynamic> spots = await dbpediaService.fetchTouristSpots('Philippines');
    setState(() {
      touristSpots = spots;
    });
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
  
 Future<List<PlaceInfo>> fetchDestinations() async {
  await Future.delayed(const Duration(seconds: 1)); // Optional: simulate network delay
  // Return the hardcoded list of places
  return places;
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
        _buildTouristSpotsList(), // Preserved function

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
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                PlaceInfo place = destinations[index];
                return Card(
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
                          child: Image.asset(
                            place.image, 
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
                              place.name, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(place.location, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}


Widget _buildTouristSpotsList() {
  if (_touristSpots.isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded, // Search icon to encourage user action
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            "No tourist spots found.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Search for any place you'd like to explore, and we'll load the tourist spots for that location.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _touristSpots.length,
    itemBuilder: (context, index) {
      final spot = _touristSpots[index];
      final imageUrl = spot['imageUrl'] ?? 
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png'; // Default if no image

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/480px-No_image_available.svg.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot['name'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        spot['description'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: () {
                            // Action when 'View More' is pressed
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  spot: spot,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "View More",
                            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
                          ),
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
                  offset: Offset(0, -4),
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



  // Helper method to build navigation icons
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
      gradient: LinearGradient(
        colors: [Colors.orange, const Color.fromARGB(255, 255, 230, 0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
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
            image: DecorationImage(
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
        Icon(
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
