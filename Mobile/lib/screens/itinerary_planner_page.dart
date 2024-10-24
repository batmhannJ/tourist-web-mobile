import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  void initState() {
    super.initState();
    _loadTravelItineraries();
  }

  Future<void> _loadTravelItineraries() async {
    final prefs = await SharedPreferences.getInstance();
    String? itinerariesString = prefs.getString('travelItineraries');
    if (itinerariesString != null) {
      setState(() {
        travelItineraries = List<Map<String, dynamic>>.from(json.decode(itinerariesString));
      });
    }
  }

Future<void> _saveTravelItineraries() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('travelItineraries', json.encode(travelItineraries));
}

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
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Destination
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              itinerary['destination'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Staying Period
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Staying Period:',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    itinerary['stayingPeriod'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                '₱${itinerary['budget']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.black26),

          // Daily Itinerary Title
          const Text(
            'Daily Itinerary:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),

          // Daily Activities
          Column(
            children: List.generate(
              itinerary['days'].length,
              (dayIndex) {
                Map<String, dynamic> day = itinerary['days'][dayIndex];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple[100]!, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${dayIndex + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 176, 142, 39),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(
                          day['activities'].length,
                          (activityIndex) {
                            Map<String, dynamic> activity = day['activities'][activityIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => _selectTime(context, activity, dayIndex, activityIndex),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blueAccent, width: 1.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        activity['time'].isNotEmpty ? activity['time'] : 'Select Time',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: activity['time'].isEmpty ? Colors.black54 : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        activity['activity'] = value;
                                      });
                                      _saveTravelItineraries();
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Activity',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.edit),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        day['activities'].removeAt(activityIndex);
                                        _saveTravelItineraries();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            day['activities'].add({'time': '', 'activity': ''});
                            _saveTravelItineraries();
                          });
                        },
                        child: const Text('Add Activity'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 15),

       // Delete Itinerary Button
ElevatedButton(
  onPressed: () {
    _deleteItinerary(index); // Call function to delete the itinerary
  },
  child: const Text('Delete Itinerary'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.redAccent, // Changed the button color
    foregroundColor: Colors.white, // Text color
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Increased padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // More rounded corners
    ),
    elevation: 5, // Added elevation for shadow
    shadowColor: Colors.black54, // Shadow color
  ),
),

// Save All Button
ElevatedButton(
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinerary saved successfully!'),
      ),
    );
  },
  child: const Text('Save All'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.greenAccent, // Changed the button color
    foregroundColor: Colors.white, // Text color
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Increased padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // More rounded corners
    ),
    elevation: 5, // Added elevation for shadow
    shadowColor: Colors.black54, // Shadow color
  ),
),

        ],
      ),
    ),
  );
}

// Function to delete an itinerary
void _deleteItinerary(int index) {
  setState(() {
    travelItineraries.removeAt(index); // Remove the itinerary at the given index
    _saveTravelItineraries(); // Save the updated list
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Itinerary deleted successfully!'),
    ),
  );
}


// Function to display the time picker
Future<void> _selectTime(BuildContext context, Map<String, dynamic> activity, int dayIndex, int activityIndex) async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (picked != null) {
    String formattedTime = picked.format(context); // Format the time
    setState(() {
      activity['time'] = formattedTime; // Update the time in the activity
    });
    _saveTravelItineraries(); // Save changes
  }
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Container for Staying Period
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Border color
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stayingPeriod.isNotEmpty ? stayingPeriod : 'Select Staying Period',
                          style: TextStyle(
                            color: stayingPeriod.isNotEmpty ? Colors.black : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            DateTimeRange? pickedRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedRange != null) {
                              setState(() {
                                stayingPeriod =
                                    '${pickedRange.start.toLocal().toString().split(' ')[0]} to ${pickedRange.end.toLocal().toString().split(' ')[0]}';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                          ),
                          child: const Text('Select', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    onChanged: (value) => budget = value,
                    decoration: InputDecoration(
                      labelText: 'Budget',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
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
                  _buildDayActivitiesTextField(days), // Assuming this function is defined elsewhere
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
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
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
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
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

  if (newItinerary != null) {
    setState(() {
      travelItineraries.add(newItinerary);
      _saveTravelItineraries(); // Save itinerary after adding
    });
  }
}


void _editTravelItinerary(int index) async {
  TextEditingController destinationController = TextEditingController(text: travelItineraries[index]['destination']);
  TextEditingController budgetController = TextEditingController(text: travelItineraries[index]['budget']);
  String stayingPeriod = travelItineraries[index]['stayingPeriod'];
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
                  
                  // Add Calendar Picker for Staying Period
                  ElevatedButton(
                    onPressed: () async {
                      DateTimeRange? pickedRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedRange != null) {
                        setState(() {
                          stayingPeriod =
                              '${pickedRange.start.toString().split(' ')[0]} to ${pickedRange.end.toString().split(' ')[0]}';
                        });
                      }
                    },
                    child: const Text('Edit Staying Period'),
                  ),
                  stayingPeriod.isNotEmpty
                      ? Text(
                          'Staying Period: $stayingPeriod',
                          style: const TextStyle(fontSize: 16),
                        )
                      : const SizedBox.shrink(),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
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
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'destination': destinationController.text,
                    'stayingPeriod': stayingPeriod,
                    'budget': budgetController.text,
                    'days': days,
                  });
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  if (editedItinerary != null) {
    setState(() {
      travelItineraries[index] = editedItinerary;
      _saveTravelItineraries(); // Save itinerary after editing
    });
  }
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