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

  // Month selection feature
  String? _selectedMonth;
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
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (DateTime.now().difference(_lastActivityTime) >= _sessionTimeoutLimit) {
        // Session expired
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

  // Function to build tourist spots filtered by month
  Widget _buildTouristSpotsByMonth() {
    int selectedMonthIndex = months.indexOf(_selectedMonth!) + 1; // Convert month name to index
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
