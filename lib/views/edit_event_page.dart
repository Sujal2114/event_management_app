import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../containers/custom_headtext.dart';
import '../containers/custom_input_form.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditEventPage({
    Key? key,
    required this.eventId,
    required this.eventData,
  }) : super(key: key);

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  String? _currentImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventNameController =
        TextEditingController(text: widget.eventData['name']);
    _descriptionController =
        TextEditingController(text: widget.eventData['description']);
    _locationController =
        TextEditingController(text: widget.eventData['location']);
    _currentImageUrl = widget.eventData['imageUrl'];

    final DateTime eventDateTime = widget.eventData['dateTime'].toDate();
    _selectedDate = eventDateTime;
    _selectedTime = TimeOfDay.fromDateTime(eventDateTime);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = _currentImageUrl!;

      // Upload new image if selected
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('event_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Create event datetime
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Update event document in Firestore
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({
        'name': _eventNameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'dateTime': eventDateTime,
        'imageUrl': imageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomHeadText(text: 'Event Details'),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _eventNameController,
                        decoration: InputDecoration(
                          labelText: 'Event Name',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter event name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter event description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter event location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Date'),
                              subtitle: Text(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              ),
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Time'),
                              subtitle: Text(
                                _selectedTime == null
                                    ? 'Select Time'
                                    : _selectedTime!.format(context),
                              ),
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_imageFile != null)
                        Image.file(
                          _imageFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else if (_currentImageUrl != null)
                        Image.network(
                          _currentImageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Change Image'),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _updateEvent,
                          child: const Text(
                            'Update Event',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
