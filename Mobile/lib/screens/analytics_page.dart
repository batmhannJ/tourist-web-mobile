import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Analytics'),
      ),
      body: const Center(
        child: Text(
          'Here is your Data Analytics',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
