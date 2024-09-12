import 'package:flutter/material.dart';

class Bookmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookMark'),
      ),
      body: Center(
        child: Text(
          'This is the Data Analytics Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}