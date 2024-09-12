import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';
import 'package:flutter_application_2/screens/Home/widgets/recommended_card.dart';
import 'package:flutter_application_2/screens/detailscreen/detail_screen.dart';
import 'package:flutter_application_2/screens/bookmark_page.dart'; // Import the DataAnalyticsPage
import 'package:flutter_application_2/screens/map_page.dart'; // Import the MapPage
import 'package:flutter_application_2/screens/itinerary_planner_page.dart'; // Import the ItineraryPlannerPage
import 'package:flutter_application_2/screens/profile_account.dart'; // Import the ProfileAccountPage
import 'package:flutter_application_2/utilities/colors.dart';

import 'widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Column(
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
                    MaterialPageRoute(builder: (context) => Bookmark()),
                  );
                },
                child: Column(
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
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
                child: Column(
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
                    MaterialPageRoute(builder: (context) => ItineraryPlannerPage()),
                  );
                },
                child: Column(
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
                    MaterialPageRoute(builder: (context) => ProfileAccountPage()),
                  );
                },
                child: Column(
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
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundImage: AssetImage("assets/images/welcome.jpeg"),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      RichText(
                        text: TextSpan(
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
                SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Explore new destinations",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
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
                                    decoration: InputDecoration(
                                      hintText: "Search your destination",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                                CircleAvatar(
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
                SizedBox(
                  height: 20,
                ),
                Row(
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
                SizedBox(
                  height: 10,
                ),
                Container(
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
                SizedBox(
                  height: 10,
                ),
                Row(
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
                SizedBox(
                  height: 10,
                ),
                Container(
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
    );
  }
}
