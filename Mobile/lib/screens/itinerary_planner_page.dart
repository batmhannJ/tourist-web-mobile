import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Itinerary',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat',
      ),
      home: const ItineraryPlannerPage(),
    );
  }
}

class ItineraryPlannerPage extends StatefulWidget {
  const ItineraryPlannerPage({super.key});

  @override
  _ItineraryPlannerPageState createState() => _ItineraryPlannerPageState();
}

class _ItineraryPlannerPageState extends State<ItineraryPlannerPage> {
  List<Map<String, dynamic>> travelItineraries = [];

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Travel Itinerary',
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.orange, // Set AppBar background to orange
      leading: IconButton(
        icon: const Icon(Icons.arrow_back), // Change to back button icon
        onPressed: () {
          Navigator.pop(context); // Navigate back to the previous screen
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Handle notifications
          },
        ),
      ],
    ),
    body: Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Expanded(
            child: travelItineraries.isNotEmpty
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: travelItineraries.length,
                    itemBuilder: (context, index) {
                      return _buildTravelCard(index);
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.travel_explore,
                          size: 80,
                          color: Colors.deepPurple[200],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No itineraries available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addTravelItinerary,
      backgroundColor: Colors.deepPurpleAccent,
      child: const Icon(Icons.add, size: 30, color: Colors.white),
    ),
  );
}


Widget _buildTravelCard(int index) {
  Map<String, dynamic> itinerary = travelItineraries[index];

  return SingleChildScrollView(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of the screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination and Edit/Delete Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  itinerary['destination'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      _editTravelItinerary(index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        travelItineraries.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Staying Period and Budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Staying Period:',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                itinerary['stayingPeriod'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget:',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                '₱${itinerary['budget']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Daily Itinerary Section
          const Divider(color: Colors.black26),
          const Text(
            'Daily Itinerary:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),

          Column(
            children: List.generate(
              itinerary['days'].length,
              (dayIndex) {
                Map<String, dynamic> day = itinerary['days'][dayIndex];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${dayIndex + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 176, 142, 39),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Activity List
                      Column(
                        children: List.generate(
                          day['activities'].length,
                          (activityIndex) {
                            Map<String, dynamic> activity = day['activities'][activityIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                children: [
                                  TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        activity['time'] = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Time',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10), // Space between time and activity fields
                                  TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        activity['activity'] = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Activity',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5), // Space between activity fields
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        day['activities'].removeAt(activityIndex);
                                      });
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red, // Set text color to red
                                        fontWeight: FontWeight.bold, // Optional: make the text bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            day['activities'].add({'time': '', 'activity': ''});
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Activity'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}


void _addTravelItinerary() async {
  Map<String, dynamic> newItinerary = await showDialog(
    context: context,
    builder: (BuildContext context) {
      String destination = '';
      String stayingPeriod = '';
      String budget = '';
      List<Map<String, dynamic>> days = [];
      int dayCounter = 0;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Add New Travel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) => destination = value,
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    onChanged: (value) => stayingPeriod = value,
                    decoration: InputDecoration(
                      labelText: 'Staying Period',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    onChanged: (value) => budget = value,
                    decoration: InputDecoration(
                      labelText: 'Budget',
                      border: OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.money),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Days and Activities:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDayActivitiesTextField(days),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            days.add({'activities': []});
                            dayCounter++;
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Day'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Corrected
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      Text('$dayCounter days added'),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (dayCounter > 0) {
                            setState(() {
                              days.removeLast();
                              dayCounter--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove),
                        label: const Text('Remove Day'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Corrected
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'destination': destination,
                            'stayingPeriod': stayingPeriod,
                            'budget': budget,
                            'days': days,
                          });
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

    setState(() {
      travelItineraries.add(newItinerary);
    });
    }

  void _editTravelItinerary(int index) async {
    TextEditingController destinationController = TextEditingController(text: travelItineraries[index]['destination']);
    TextEditingController stayingPeriodController = TextEditingController(text: travelItineraries[index]['stayingPeriod']);
    TextEditingController budgetController = TextEditingController(text: travelItineraries[index]['budget']);
    List<Map<String, dynamic>> days = List.from(travelItineraries[index]['days']);
    int dayCounter = days.length;

    Map<String, dynamic> editedItinerary = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Travel'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stayingPeriodController,
                      decoration: const InputDecoration(
                        labelText: 'Staying Period',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Days and Activities:',
                      style
                      : TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildDayActivitiesTextField(days),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              days.add({'activities': []});
                              dayCounter++;
                            });
                          },
                          child: const Text('Add Day'),
                        ),
                        const SizedBox(width: 10),
                        Text('$dayCounter days added'),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (dayCounter > 0) {
                              setState(() {
                                days.removeLast();
                                dayCounter--;
                              });
                            }
                          },
                          child: const Text('Remove Day'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[                TextButton(                  onPressed: () {                    Navigator.pop(context);                  },                  child: const Text('Cancel'),                ),                ElevatedButton(                  onPressed: () {                    Navigator.pop(context, {                      'destination': destinationController.text,                      'stayingPeriod': stayingPeriodController.text,                      'budget': budgetController.text,                      'days': days,                    });                  },                  child: const Text('Save'),                ),              ],
            );
          },
        );
      },
    );

    setState(() {
      travelItineraries[index] = editedItinerary;
    });
    }

 Widget _buildDayActivitiesTextField(List<Map<String, dynamic>> days) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(
      days.length,
      (dayIndex) {
        Map<String, dynamic> day = days[dayIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: List.generate(
                day['activities'].length,
                (activityIndex) {
                  Map<String, dynamic> activity = day['activities'][activityIndex];
                  TextEditingController timeController = TextEditingController(text: activity['time']);
                  TextEditingController activityController = TextEditingController(text: activity['activity']);
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          onChanged: (value) {
                            setState(() {
                              activity['time'] = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Time',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: activityController,
                          onChanged: (value) {
                            setState(() {
                              activity['activity'] = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Activity',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            day['activities'].removeAt(activityIndex);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            if (dayIndex != days.length - 1) const Divider(),
          ],
        );
      },
    ),
  );
}
}

