import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../containers/custom_headtext.dart';
import '../containers/custom_input_form.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      initialTime: TimeOfDay.now(),
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

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // Create event document in Firestore
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('events').add({
        'name': _eventNameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'dateTime': Timestamp.fromDate(eventDateTime),
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
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
        title: const Text('Create Event'),
        backgroundColor:
            Colors.blue, // Using Flutter's built-in Colors instead of AppColors
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomHeadText(text: 'Create a New Event'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
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
                  fillColor: Colors.white,
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
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child:
                    Text(_imageFile == null ? 'Select Image' : 'Change Image'),
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
