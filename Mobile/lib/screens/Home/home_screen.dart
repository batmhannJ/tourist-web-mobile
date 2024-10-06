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
import 'dart:async'; 
import 'widgets/category_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/providers/user_provider.dart';
import 'package:flutter_application_2/services/dbpedia_service.dart';
// Make sure this line is present


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

  List<dynamic> _touristSpots = [];
  final List<String> _imageUrls = [];
  String? _selectedMonth;
  final Map<String, List<dynamic>> _cachedResults = {};
  Timer? _debounce;

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
  } catch (e) {
    print('Error searching for spots: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error searching for spots: $e')),
    );
  }
}


void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    _searchForSpots(query);  // Call the updated function
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
                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5, offset: const Offset(0, 4))],
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
          _buildDropdownToSelectMonth(),
          if (_selectedMonth != null) _buildTouristSpotsByMonth(),
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
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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


  // Function to display Unsplash search results
 Widget _buildSearchResults() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 15),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Image.network(
              _imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text('Image could not be loaded'));
              },
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
