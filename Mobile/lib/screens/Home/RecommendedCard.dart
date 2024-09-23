import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';

class RecommendedCard extends StatelessWidget {
  final PlaceInfo placeInfo;
  final VoidCallback press;
  final VoidCallback? navigationButton; // Optional navigation button

  const RecommendedCard({
    Key? key,
    required this.placeInfo,
    required this.press,
    this.navigationButton, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Your card design here
      child: Column(
        children: [
          // Example for displaying place info
          Text(placeInfo.name),
          if (navigationButton != null) // Only show if it's provided
            ElevatedButton(
              onPressed: navigationButton,
              child: Text('Navigate'),
            ),
          TextButton(
            onPressed: press,
            child: Text('Details'),
          ),
        ],
      ),
    );
  }
}
