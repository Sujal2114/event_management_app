import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app/constants/colors.dart';
import 'package:event_management_app/database.dart';
import 'package:event_management_app/saved_data.dart';
import 'package:event_management_app/views/event_details.dart';
import 'package:flutter/material.dart';

class RSVPEvents extends StatefulWidget {
  const RSVPEvents({super.key});

  @override
  State<RSVPEvents> createState() => _RSVPEventsState();
}

class _RSVPEventsState extends State<RSVPEvents> {
  List<QueryDocumentSnapshot> events = [];
  List<Map<String, dynamic>> userEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    String userId = SavedData.getUserId();
    getAllEvents().then((value) {
      events = value.docs;
      for (var event in events) {
        List<dynamic> participants = (event.data() as Map<String, dynamic>)?['participants'] ?? [];

        if (participants.contains(userId)) {
          userEvents.add(event.data() as Map<String, dynamic>);
        }
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RSVP Events")),
      body: ListView.builder(
        itemCount: userEvents.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EventDetails(data: userEvents[index]))),
            title: Text(
              userEvents[index]["name"],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              userEvents[index]["location"],
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.check_circle,
              color: kLightGreen,
            ),
          ),
        ),
      ),
    );
  }
}
