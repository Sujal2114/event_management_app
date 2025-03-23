import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_details.dart'; // Import EventDetails screen
import 'create_event_page.dart'; // Import Create Event Page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isHovered = false; // Hover state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Track", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching events"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No events available", style: TextStyle(fontSize: 18)));
          }

          var events = snapshot.data!.docs;
          return ListView.builder(
            itemCount: events.length,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemBuilder: (context, index) {
              var event = events[index];

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.only(bottom: 15),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetails(
                          eventId: event.id,
                          eventDate: event['Date'].toDate(),
                          eventName: event['Event Name'] ?? '',
                          eventLocation: event['Location'] ?? '',
                          eventDescription: event['Description'] ?? '',
                          imageUrl: event['Image'] ?? '',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            event['Image'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 80, color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['Event Name'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text(
                                event['Location'],
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "📅 ${event['Date'].toDate().toLocal()}",
                                style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      // Floating Hover Button
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: isHovered ? 70 : 56, // Increases size on hover
          width: isHovered ? 70 : 56,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateEventPage()),
              );
            },
            backgroundColor: Colors.blueAccent,
            elevation: 10,
            child: Icon(Icons.add, size: isHovered ? 35 : 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
