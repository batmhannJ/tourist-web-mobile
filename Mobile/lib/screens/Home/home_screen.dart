import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';
import 'package:flutter_application_2/screens/Home/widgets/recommended_card.dart';
import 'package:flutter_application_2/screens/detailscreen/detail_screen.dart';
import 'package:flutter_application_2/screens/bookmark_page.dart';
import 'package:flutter_application_2/screens/map_page.dart';
import 'package:flutter_application_2/screens/itinerary_planner_page.dart';
import 'package:flutter_application_2/screens/profile_account.dart';
import 'package:flutter_application_2/utilities/colors.dart';
import 'package:flutter_application_2/services/auth_services.dart';
import 'package:flutter_application_2/services/unsplash_service.dart'; // Unsplash service import
import 'dart:async'; 
import 'widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/user_provider.dart';
import 'package:flutter_application_2/services/TouristSpotService.dart';

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
  final TouristSpotService _touristSpotService = TouristSpotService();
  final UnsplashService _unsplashService = UnsplashService(); // Unsplash service

  List<dynamic> _touristSpots = [];
  List<String> _imageUrls = []; // Store Unsplash images
  String? _selectedMonth;
  final Map<String, List<dynamic>> _cachedResults = {}; // Cache search results
  Timer? _debounce;

  List<String> months = [
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _debounce?.cancel(); // Cancel debounce timer
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
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

  // Function to search for tourist spots using the API with caching and delay
  void _searchForSpots(String query) async {
    if (_cachedResults.containsKey(query)) {
      setState(() {
        _touristSpots = _cachedResults[query]!;
      });
      return;
    }

    try {
      final spots = await _touristSpotService.searchTouristSpots(query);
      setState(() {
        _touristSpots = spots;
        _cachedResults[query] = spots;
      });
    } catch (e) {
      print('Error searching for spots: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching for spots: $e')),
      );
    }
  }

  // Search Unsplash for images
  void _searchForImages(String query) async {
    try {
      final images = await _unsplashService.searchImages(query);
      setState(() {
        _imageUrls = images;
      });
    } catch (e) {
      print('Error fetching images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching images: $e')),
      );
    }
  }

  // Function to debounce user input
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchForSpots(query);
      _searchForImages(query); // Fetch images from Unsplash
    });
  }

  // Function to build tourist spots filtered by month
  Widget _buildTouristSpotsByMonth() {
    if (_selectedMonth == null) {
      return const SizedBox(); // If no month selected, return empty
    }

    int selectedMonthIndex = months.indexOf(_selectedMonth!) + 1; // Convert month to index
    List<PlaceInfo> filteredPlaces = places.where((place) {
      return place.bestMonths.contains(selectedMonthIndex);
    }).toList();

    if (filteredPlaces.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No tourist spots found for this month."),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPlaces.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 15),
          child: RecommendedCard(
            placeInfo: filteredPlaces[index],
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    placeInfo: filteredPlaces[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Function to display Unsplash search results
  Widget _buildSearchResults() {
    if (_imageUrls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No images found.'),
      );
    }

    // Use MediaQuery to determine screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 200).round(); // Adjust based on screen width

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, // Dynamic grid columns
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _imageUrls[index],
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return const Icon(Icons.error); // Handle error case
            },
          ),
        );
      },
    );
  }

  // Build the main content that was duplicated
  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Row(
            children: [
              Text("Category", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          _buildCategorySection(),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text("Popular Tourist Spots", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          _buildDropdownToSelectMonth(),
          if (_selectedMonth != null) _buildTouristSpotsByMonth(),
          const SizedBox(height: 20),
          _buildTouristSpotsList(),  // Add this line to display the fetched tourist spots
          const SizedBox(height: 20),
          _buildSearchResults(),  // Add this line to display Unsplash search results
        ],
      ),
    );
  }

  // Build the list of tourist spots
  Widget _buildTouristSpotsList() {
    if (_touristSpots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No tourist spots found."),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _touristSpots.length,
      itemBuilder: (context, index) {
        final spot = _touristSpots[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              spot['imageUrl'] ?? 'https://example.com/default_image.jpg',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Image.asset('assets/images/tagtay.jpg', width: 80, height: 80, fit: BoxFit.cover);
              },
            ),
          ),
          title: Text(spot['name'] ?? 'Unknown'),
          subtitle: Text(spot['country'] ?? 'Unknown country'),
          onTap: () {
            // Handle tap if needed, perhaps navigate to a detail screen
          },
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
        backgroundColor: kWhiteClr,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavIcon(Icons.home, "Home", () {}),
                _buildNavIcon(Icons.bookmark, "Bookmarks", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Bookmark()));
                }),
                _buildNavIcon(Icons.map, "Map", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MapPage()));
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(userName),
                const SizedBox(height: 15),
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
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundImage: AssetImage("assets/images/welcome.jpeg"),
          ),
          const SizedBox(width: 15),
          RichText(
            text: TextSpan(
              text: "Hello",
              style: const TextStyle(color: Colors.white, fontSize: 18),
              children: [
                TextSpan(
                  text: userName.isNotEmpty ? ", $userName" : ", User",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the search section
  Widget _buildSearchSection() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(20),
    ),
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        const Text(
          "Explore new destinations",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Material(
          borderRadius: BorderRadius.circular(100),
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
              color: kWhiteClr,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: _onSearchChanged, // Use debounced search method
                      decoration: const InputDecoration(
                        hintText: "Search your destination",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: kPrimaryClr,
                    child: Icon(Icons.sort_by_alpha_sharp, color: kWhiteClr),
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


  // Helper method to build the category section
  Widget _buildCategorySection() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Row(
            children: [
              CategoryCard(
                press: () {},
                image: "assets/images/app.jpg",
                title: "Tagaytay",
              ),
              CategoryCard(
                press: () {},
                image: "assets/images/antipolo1.jpg",
                title: "Antipolo, Rizal",
              ),
              CategoryCard(
                press: () {},
                image: "assets/images/baguio.jpg",
                title: "Baguio",
              ),
              CategoryCard(
                press: () {},
                image: "assets/images/siargao1-img.jpg",
                title: "Siargao",
              ),
              CategoryCard(
                press: () {},
                image: "assets/images/ilocossur1-img.jpg",
                title: "Ilocos Sur",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build the month selection dropdown
  Widget _buildDropdownToSelectMonth() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedMonth,
        hint: const Text("Select a month"),
        onChanged: (newValue) {
          setState(() {
            _selectedMonth = newValue;
          });
        },
        items: months.map((month) {
          return DropdownMenuItem(
            value: month,
            child: Text(month),
          );
        }).toList(),
      ),
    );
  }
}
