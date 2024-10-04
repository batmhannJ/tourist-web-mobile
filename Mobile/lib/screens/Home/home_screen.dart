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
  final UnsplashService _unsplashService = UnsplashService();

  List<dynamic> _touristSpots = [];
  List<String> _imageUrls = [];
  String? _selectedMonth;
  final Map<String, List<dynamic>> _cachedResults = {};
  Timer? _debounce;

  List<String> months = [
    "January", "February", "March", "April", "May", "June", "July", "August",
    "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _startSessionTimer();
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchForSpots(query);
      _searchForImages(query);
    });
  }

  // Function to build tourist spots filtered by month
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

   // Calendar-like grid to display months
 Widget _buildMonthGrid() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,  // 3 months per row
        childAspectRatio: 1.5,  // Adjust for more calendar-like appearance
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: months.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedMonth == months[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMonth = months[index];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 10, offset: Offset(0, 4))]
                  : [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5, offset: Offset(0, 4))],
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey[400]!,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    ),
  );
}


  // Build the main content
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
        const Text("Select a Month", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildMonthGrid(),
        const SizedBox(height: 20),
        if (_selectedMonth != null) _buildTouristSpotsByMonth(),
          const SizedBox(height: 20),
          _buildTouristSpotsList(),
          const SizedBox(height: 20),
          _buildSearchResults(),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10), // Space between tourist spots
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the content vertically
            children: [
              // Image for the tourist spot
              Padding(
                padding: const EdgeInsets.only(left: 16.0), // Add space to the left of the image
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    spot['imageUrl'] ?? 'https://example.com/default_image.jpg',
                    fit: BoxFit.cover,
                    height: 100, // Set a fixed height for the image
                    width: 100, // Set a fixed width for the image
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
                      return Image.asset('assets/images/tagtay.jpg', fit: BoxFit.cover);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10), // Space between the image and text
              // Column for text beside the image
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                  children: [
                    Text(
                      spot['name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      spot['country'] ?? 'Unknown country',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to display Unsplash search results for a specific tourist spot
  Widget _buildUnsplashImages(String spotName) {
    // Filter Unsplash images based on the tourist spot name
    final filteredImages = _imageUrls.where((url) => url.contains(spotName)).toList();

    if (filteredImages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No related images found.'),
      );
    }

    return SizedBox(
      height: 100, // Set a fixed height for the image container
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0), // Space between images
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                filteredImages[index],
                fit: BoxFit.cover,
                height: 100, // Set a fixed height for the image
                width: 100, // Set a fixed width for the image
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
                  return const Icon(Icons.error);
                },
              ),
            ),
          );
        },
      ),
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

    return const SizedBox.shrink(); // No longer needed as we're displaying in the tourist spots list
  }

  // Build the search results from Unsplash and display below the tourist spots
  void _searchImagesAndDisplay(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchForImages(query);
    });
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
