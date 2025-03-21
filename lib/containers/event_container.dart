import 'package:flutter/material.dart';
import 'package:event_management_app/containers/format_datetime.dart';

class EventContainer extends StatelessWidget {
  final String eventName;
  final DateTime eventDate;
  final String eventLocation;
  final String eventDescription;
  final VoidCallback onTap;

  const EventContainer({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.eventDescription,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    formatDateTime(eventDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    eventLocation,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                eventDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
