import 'package:flutter/material.dart';

class Bookmark extends StatelessWidget {
  const Bookmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookMark'),
      ),
      body: const Center(
        child: Text(
          'This is the Data Analytics Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}