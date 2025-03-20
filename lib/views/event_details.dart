import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_management_app/constants/colors.dart';
import 'package:event_management_app/containers/format_datetime.dart';
import 'package:event_management_app/database.dart';
import 'package:event_management_app/saved_data.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  const EventDetails({super.key, required this.data});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  bool isRSVPedEvent = false;
  String id = "";
  List<dynamic> participants = [];

  bool isUserPresent(List<dynamic> participants, String userId) {
    return participants.contains(userId);
  }

  @override
  void initState() {
    id = SavedData.getUserId();
    participants = widget.data["participants"] ?? [];
    isRSVPedEvent = isUserPresent(participants, id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                  child: Image.network(widget.data["image"], fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 25,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 45,
                left: 8,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${formatDate(widget.data["datetime"])}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${formatTime(widget.data["datetime"])}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 8,
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.data["location"]}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.data["name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.share),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data["description"],
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.data["participants"].length} people are attending.",
                  style: const TextStyle(
                    color: kLightGreen,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Special Guests ",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.data["guests"] == "" ? "None" : widget.data["guests"]}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sponsers ",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.data["sponsers"] == "" ? "None" : widget.data["sponsers"]}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  "More Info ",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Event Type : ${widget.data["isInPerson"] == true ? "In Person" : "Virtual"}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Time : ${formatTime(widget.data["datetime"])}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Location : ${widget.data["location"]}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _launchUrl(
                      "https://www.google.com/maps/search/?api=1&query=${widget.data["location"]}",
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text("Open in Google Maps"),
                ),
                const SizedBox(height: 8),
                isRSVPedEvent
                    ? SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MaterialButton(
                          color: kLightGreen,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("You are attending this event."),
                              ),
                            );
                          },
                          child: const Text(
                            "Attending Event",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MaterialButton(
                          color: kLightGreen,
                          onPressed: () {
                            rsvpEvent(
                              widget.data["participants"],
                              widget.data["id"],
                            ).then((value) {
                              if (value) {
                                setState(() {
                                  isRSVPedEvent = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("RSVP Successful !!!"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Something went worng. Try Agian.",
                                    ),
                                  ),
                                );
                              }
                            });
                          },
                          child: const Text(
                            "RSVP Event",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
