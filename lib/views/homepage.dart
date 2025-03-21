import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_management_app/views/event_details.dart';
import 'package:event_management_app/views/profile_page.dart';
import 'package:event_management_app/views/manage_events.dart';
import 'package:event_management_app/views/rsvp_events.dart';
import 'package:event_management_app/views/create_event_page.dart';
import 'package:event_management_app/containers/event_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final eventData =
                          events[index].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: EventContainer(
                          eventName: eventData['eventName'] ?? '',
                          eventDate: eventData['eventDate']?.toDate() ??
                              DateTime.now(),
                          eventLocation: eventData['eventLocation'] ?? '',
                          eventDescription: eventData['eventDescription'] ?? '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetails(
                                  eventId: events[index].id,
                                  eventData: eventData,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Manage Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'RSVP Events',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageEvents()),
            );
          } else if (index == 2) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const RsvpEvents()),
            // );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
