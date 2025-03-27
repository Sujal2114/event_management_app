import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_management_app/containers/format_datetime.dart';
import 'package:event_management_app/models/event_rating.dart';

class EventDetails extends StatefulWidget {
  final String eventId;
  final DateTime eventDate;
  final String eventName;
  final String eventLocation;
  final String eventDescription;
  final String imageUrl;

  const EventDetails({
    Key? key,
    required this.eventId,
    required this.eventDate,
    required this.eventName,
    required this.eventLocation,
    required this.eventDescription,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  bool _isRsvped = false;
  bool _isLoading = true;
  double _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkRsvpStatus();
  }

  Future<void> _checkRsvpStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .collection('rsvps')
          .doc(user.uid)
          .get();

      setState(() {
        _isRsvped = doc.exists;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _toggleRsvp() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please login to RSVP')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final rsvpRef = FirebaseFirestore.instance
  //         .collection('events')
  //         .doc(widget.eventId)
  //         .collection('rsvps')
  //         .doc(user.uid);

  //     if (_isRsvped) {
  //       await rsvpRef.delete();
  //     } else {
  //       await rsvpRef.set({
  //         'timestamp': FieldValue.serverTimestamp(),
  //         'userId': user.uid,
  //         'userEmail': user.email,
  //       });
  //     }

  //     setState(() {
  //       _isRsvped = !_isRsvped;
  //       _isLoading = false;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(_isRsvped ? 'RSVP successful!' : 'RSVP cancelled'),
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to update RSVP status')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            formatDateTime(widget.eventDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.eventLocation,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.eventDescription,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rate this event:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => IconButton(
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = index + 1.0;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _reviewController,
                        decoration: const InputDecoration(
                          labelText: 'Write your review',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) {
                                    ScaffoldMessenger.of(context).rshowSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please login to submit a review'),
                                      ),
                                    );
                                    return;
                                  }

                                  if (_rating == 0) {
                                    ScaffoldMessenger.of(context).rshowSnackBar(
                                      const SnackBar(
                                        content: Text('Please select a rating'),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isSubmitting = true;
                                  });

                                  try {
                                    final rating = EventRating(
                                      userId: user.uid,
                                      userEmail: user.email!,
                                      rating: _rating,
                                      review: _reviewController.text.trim(),
                                      timestamp: DateTime.now(),
                                    );

                                    await FirebaseFirestore.instance
                                        .collection('events')
                                        .doc(widget.eventId)
                                        .collection('ratings')
                                        .doc(user.uid)
                                        .set(rating.toMap());

                                    ScaffoldMessenger.of(context).rshowSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Rating added successfully!'),
                                      ),
                                    );

                                    Navigator.of(context)
                                        .pushReplacementNamed('/');
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).rshowSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Failed to submit rating'),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isSubmitting = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('Submit Review'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
