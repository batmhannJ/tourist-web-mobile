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
        title: const Text('Travel Itinerary'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              onPressed: _addTravelItinerary,
              child: const Text('Add New Travel'),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: travelItineraries.length,
              itemBuilder: (context, index) {
                return _buildTravelCard(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelCard(int index) {
    Map<String, dynamic> itinerary = travelItineraries[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Destination: ${itinerary['destination']}',
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editTravelItinerary(index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
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
            const SizedBox(height: 5),
            Text(
              'Staying Period: ${itinerary['stayingPeriod']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Budget: ${itinerary['budget']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Itinerary:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                itinerary['days'].length,
                (dayIndex) {
                  Map<String, dynamic> day = itinerary['days'][dayIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${dayIndex + 1}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: List.generate(
                          day['activities'].length,
                          (activityIndex) {
                            Map<String, dynamic> activity = day['activities'][activityIndex];
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
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
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            day['activities'].add({'time': '', 'activity': ''});
                          });
                        },
                        child: const Text('Add Activity'),
                      ),
                      const SizedBox(height: 20),
                    ],
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
            return AlertDialog(
              title: const Text('Add New Travel'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      onChanged: (value) => destination = value,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => stayingPeriod = value,
                      decoration: const InputDecoration(
                        labelText: 'Staying Period',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => budget = value,
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
                      'destination': destination,
                      'stayingPeriod': stayingPeriod,
                      'budget': budget,
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

