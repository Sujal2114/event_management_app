import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app/constants/colors.dart';
import 'package:event_management_app/database.dart';
import 'package:event_management_app/views/edit_event_page.dart';
import 'package:event_management_app/views/event_details.dart';
import 'package:flutter/material.dart';

class ManageEvents extends StatefulWidget {
  const ManageEvents({super.key});

  @override
  State<ManageEvents> createState() => _ManageEventsState();
}

class _ManageEventsState extends State<ManageEvents> {
  List<Map<String, dynamic>> userCreatedEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    manageEvents().then((value) {
      userCreatedEvents = value;
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Events")),
      body: ListView.builder(
        itemCount: userCreatedEvents.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EventDetails(data: userCreatedEvents[index]))),
            title: Text(
              userCreatedEvents[index]["name"],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "${userCreatedEvents[index]["participants"].length} Participants",
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditEventPage(
                              image: userCreatedEvents[index]["image"],
                              name: userCreatedEvents[index]["name"],
                              desc: userCreatedEvents[index]["description"],
                              loc: userCreatedEvents[index]["location"],
                              datetime: userCreatedEvents[index]["datetime"],
                              guests: userCreatedEvents[index]["guests"],
                              sponsers: userCreatedEvents[index]["sponsers"],
                              isInPerson: userCreatedEvents[index]
                                  ["isInPerson"],
                              docID: userCreatedEvents[index]["id"],
                            )));
                refresh();
              },
              icon: const Icon(
                Icons.edit,
                color: kLightGreen,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
