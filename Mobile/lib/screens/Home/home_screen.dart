import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';
import 'package:flutter_application_2/screens/Home/widgets/recommended_card.dart';
import 'package:flutter_application_2/screens/detailscreen/detail_screen.dart';
import 'package:flutter_application_2/screens/bookmark_page.dart'; // Import the DataAnalyticsPage
import 'package:flutter_application_2/screens/map_page.dart'; // Import the MapPage
import 'package:flutter_application_2/screens/itinerary_planner_page.dart'; // Import the ItineraryPlannerPage
import 'package:flutter_application_2/screens/profile_account.dart'; // Import the ProfileAccountPage
import 'package:flutter_application_2/utilities/colors.dart';
import 'package:flutter_application_2/services/auth_services.dart'; // Import the correct file for AuthService
import 'dart:async'; // Import Timer
import 'widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Timer? _sessionTimer;
  static const Duration _sessionTimeoutLimit = Duration(minutes: 2); // 2 minutes of inactivity
  DateTime _lastActivityTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startSessionTimer(); // Call the method here to start the timer
  }

  @override
  void dispose() {
    _sessionTimer?.cancel(); // Cancel timer when disposing
    super.dispose();
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
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

  @override
  Widget build(BuildContext context) {
      return GestureDetector(
      onPanUpdate: (_) => _updateActivityTime(), // Detect user interaction
      onTap: () => _updateActivityTime(), // Detect user interaction
      onPanEnd: (_) => _updateActivityTime(), // Detect user interaction
      child: Scaffold(
      backgroundColor: kWhiteClr,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to the home page
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home,
                      size: 40,
                      color: kPrimaryClr,
                    ),
                    Text('Home'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the data analytics page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Bookmark()),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark,
                      size: 40,
                    ),
                    Text('Data'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the map page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPage()),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map,
                      size: 40,
                    ),
                    Text('Map'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the itinerary planner page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ItineraryPlannerPage()),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 40,
                    ),
                    Text('Planner'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the profile account page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileAccountPage()),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 40,
                    ),
                    Text('Account'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //app bar
                Container(
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
                      const SizedBox(
                        width: 15,
                      ),
                      RichText(
                        text: const TextSpan(
                          text: "Hello",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          children: [
                            TextSpan(
                              text: ", Name",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //search section
                const SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Text(
                        "Explore new destinations",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Material(
                        borderRadius: BorderRadius.circular(100),
                        elevation: 5,
                        child: Container(
                          decoration: BoxDecoration(
                              color: kWhiteClr, borderRadius: BorderRadius.circular(100)),
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
                                  child: Icon(
                                    Icons.sort_by_alpha_sharp,
                                    color: kWhiteClr,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //category
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  children: [
                    Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
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
                            image: "assets/images/ilocos1.jpg",
                            title: "Ilocos Sur",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //Recommended
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  children: [
                    Text(
                      "Popular Tourist Spots",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 350,
                  child: ListView.builder(
                    itemCount: places.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 5, right: 15),
                        child: Row(
                          children: [
                            RecommendedCard(
                              placeInfo: places[index],
                              press: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      placeInfo: places[index],
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
