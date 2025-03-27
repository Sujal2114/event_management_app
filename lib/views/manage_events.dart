import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_management_app/containers/event_container.dart';
import 'package:event_management_app/views/edit_event_page.dart';

class ManageEventsPage extends StatelessWidget {
  const ManageEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
      ),
      body: user == null
          ? const Center(child: Text('Please login to manage events'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('creatorId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No events found. Create some events!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final eventDoc = snapshot.data!.docs[index];
                    final eventData = eventDoc.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(eventDoc.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Event'),
                            content: const Text(
                                'Are you sure you want to delete this event?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('events')
                              .doc(eventDoc.id)
                              .delete();

                          ScaffoldMessenger.of(context).rshowSnackBar(
                            const SnackBar(
                              content: Text('Event deleted successfully'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).rshowSnackBar(
                            SnackBar(
                              content: Text('Error deleting event: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: EventContainer(
                        eventName: eventData['name'] ?? '',
                        eventDate:
                            (eventData['dateTime'] as Timestamp).toDate(),
                        eventLocation: eventData['location'] ?? '',
                        eventDescription: eventData['description'] ?? '',
                        eventImage: eventData['imageUrl'] ?? '',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditEventPage(
                                docID: eventDoc.id,
                                image: eventData['imageUrl'] ?? '',
                                name: eventData['name'] ?? '',
                                desc: eventData['description'] ?? '',
                                loc: eventData['location'] ?? '',
                                datetime: (eventData['dateTime'] as Timestamp)
                                    .toDate(),
                                guests: eventData['guests'] ?? [],
                                sponsers: eventData['sponsers'] ?? [],
                                isInPerson: eventData['isInPerson'] ?? true,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
