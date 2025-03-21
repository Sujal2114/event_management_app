import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../containers/event_container.dart';
import 'event_details.dart';

class RsvpEvents extends StatefulWidget {
  const RsvpEvents({super.key});

  @override
  State<RsvpEvents> createState() => _RsvpEventsState();
}

class _RsvpEventsState extends State<RsvpEvents> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RSVP Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Colors.blue, // Using Flutter's built-in Colors instead of AppColors
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('events')
            .where('rsvpUsers', arrayContains: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No RSVP events found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final eventData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final eventId = snapshot.data!.docs[index].id;

              return EventContainer(
                eventName: eventData['name'] ?? '',
                eventDescription: eventData['description'] ?? '',
                eventDate: (eventData['date'] as Timestamp).toDate(),
                eventLocation: eventData['location'] ?? '',
                eventImage: eventData['imageUrl'] ?? '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetails(
                        eventId: eventId,
                        eventData: eventData,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
