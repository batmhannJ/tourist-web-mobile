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
  Map<String, TextEditingController> _activityControllers = {};

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
        travelItineraries =
            List<Map<String, dynamic>>.from(json.decode(itinerariesString));
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
                  ? ListView.builder(
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

    return Container(
      width: double.infinity, // Full-width for single-column display
      margin: const EdgeInsets.only(bottom: 12), // Adjust spacing between cards
      padding: const EdgeInsets.all(15), // Padding for each card
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itinerary['destination'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
              const SizedBox(width: 6),
              Text(
                'Staying Period: ${itinerary['stayingPeriod']}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 16, color: Colors.teal),
              const SizedBox(width: 6),
              Text(
                'Budget: ₱${itinerary['budget']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Itinerary:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Column(
                children: List.generate(
                  itinerary['days'].length,
                  (dayIndex) {
                    Map<String, dynamic> day = itinerary['days'][dayIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day ${dayIndex + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              day['activities'].length,
                              (activityIndex) {
                                Map<String, dynamic> activity =
                                    day['activities'][activityIndex];
                                // Generate a unique key for the activity
                                String controllerKey =
                                    '$dayIndex-$activityIndex';

                                // Check if a controller already exists, otherwise create one
                                if (!_activityControllers
                                    .containsKey(controllerKey)) {
                                  _activityControllers[controllerKey] =
                                      TextEditingController(
                                          text: activity['activity']);
                                }

                                TextEditingController activityController =
                                    _activityControllers[controllerKey]!;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _selectTime(context,
                                            activity, dayIndex, activityIndex),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            activity['time'].isNotEmpty
                                                ? activity['time']
                                                : 'Set Time',
                                            style: TextStyle(
                                              color: activity['time'].isEmpty
                                                  ? Colors.grey
                                                  : Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: activityController,
                                          onChanged: (value) {
                                            setState(() {
                                              activity['activity'] = value;
                                            });
                                            _saveTravelItineraries();
                                          },
                                          decoration: const InputDecoration(
                                            hintText: 'Activity name',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            day['activities']
                                                .removeAt(activityIndex);
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
                                day['activities']
                                    .add({'time': '', 'activity': ''});
                              });
                              _saveTravelItineraries();
                            },
                            child: const Text('Add Activity'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _editTravelItinerary(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white, // Set the text color to white
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    travelItineraries.removeAt(index);
                    _saveTravelItineraries();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white, // Set the text color to white
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Itinerary saved!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white, // Set the text color to white
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Function to display the time picker
  Future<void> _selectTime(BuildContext context, Map<String, dynamic> activity,
      int dayIndex, int activityIndex) async {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Title Section
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: const Text(
                        'Add New Travel',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Destination Input Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Destination',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            TextField(
                              onChanged: (value) => destination = value,
                              decoration: const InputDecoration(
                                hintText: 'Enter destination',
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Staying Period with Calendar Pop-up
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          stayingPeriod.isNotEmpty
                              ? stayingPeriod
                              : 'Select Staying Period',
                          style: TextStyle(
                            color: stayingPeriod.isNotEmpty
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.blueGrey),
                          onPressed: () async {
                            DateTimeRange? pickedRange =
                                await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  insetPadding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1, // Dynamic horizontal padding
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.2, // Dynamic vertical padding
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    height: MediaQuery.of(context).size.height *
                                        0.6, // Adjusted height
                                    width: MediaQuery.of(context).size.width *
                                        0.85, // Adjusted width
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Select Dates',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ),
                                        if (child != null)
                                          Expanded(child: child),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            // When the range is picked, update the stayingPeriod with the selected dates
                            if (pickedRange != null) {
                              setState(() {
                                stayingPeriod =
                                    '${pickedRange.start.toLocal().toString().split(' ')[0]} to ${pickedRange.end.toLocal().toString().split(' ')[0]}';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Budget Input Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Budget',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            TextField(
                              onChanged: (value) => budget = value,
                              decoration: const InputDecoration(
                                hintText: 'Enter budget',
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Check if the width is narrow, such as on mobile
                        bool isNarrow = constraints.maxWidth < 600;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: isNarrow
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.spaceBetween,
                              children: [
                                // Add Day Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        days.add({'activities': []});
                                        dayCounter++;
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text(''),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isNarrow)
                                  const SizedBox(
                                      width:
                                          10), // Add spacing for wider layouts

                                // Day Counter Text
                                Text('$dayCounter days added',
                                    textAlign: isNarrow
                                        ? TextAlign.center
                                        : TextAlign.left),
                                if (!isNarrow)
                                  const SizedBox(
                                      width:
                                          10), // Add spacing for wider layouts

                                // Remove Day Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (dayCounter > 0) {
                                        setState(() {
                                          days.removeLast();
                                          dayCounter--;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.remove),
                                    label: const Text(''),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Save and Cancel Buttons
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
                            backgroundColor: Colors.blueGrey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save',
                              style: TextStyle(color: Colors.white)),
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
    TextEditingController destinationController =
        TextEditingController(text: travelItineraries[index]['destination']);
    TextEditingController budgetController =
        TextEditingController(text: travelItineraries[index]['budget']);
    String stayingPeriod = travelItineraries[index]['stayingPeriod'];
    List<Map<String, dynamic>> days =
        List.from(travelItineraries[index]['days']);
    int dayCounter = days.length;

    Map<String, dynamic> editedItinerary = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width * 0.1, // Wider dialog box
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // More rounded for modern look
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    20), // Uniform padding for neat spacing
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Full width for all elements
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Destination Input
                      TextField(
                        controller: destinationController,
                        decoration: const InputDecoration(
                          labelText: 'Destination',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Budget Input
                      TextField(
                        controller: budgetController,
                        decoration: const InputDecoration(
                          labelText: 'Budget',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Add / Remove Day Buttons
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
                            label: const Text(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          Text('$dayCounter days added',
                              style: const TextStyle(color: Colors.black54)),
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
                            label: const Text(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day label (e.g., "Day 1", "Day 2")
                Text(
                  'Day ${dayIndex + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 10),

                // Activities list for the day
                Column(
                  children: List.generate(
                    day['activities'].length,
                    (activityIndex) {
                      Map<String, dynamic> activity =
                          day['activities'][activityIndex];
                      TextEditingController timeController =
                          TextEditingController(text: activity['time']);
                      TextEditingController activityController =
                          TextEditingController(text: activity['activity']);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6), // Card for each activity
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: timeController,
                                  onChanged: (value) {
                                    setState(() {
                                      activity['time'] = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Time',
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
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
                                  decoration: InputDecoration(
                                    labelText: 'Activity',
                                    labelStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    day['activities'].removeAt(activityIndex);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
