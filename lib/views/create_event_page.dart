import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../constants/colors.dart';
import '../containers/custom_headtext.dart';
import '../containers/custom_input_form.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _guestsController = TextEditingController();
  final _sponsorsController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<int>? _webImage;
  String? _imageName;
  bool _isLoading = false;
  bool _isInPersonEvent = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
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
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    await input.onChange.first;
    if (input.files!.isNotEmpty) {
      final file = input.files![0];
      _imageName = file.name;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;
      setState(() {
        _webImage = (reader.result as List<int>).toList();
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _webImage == null) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text('Please fill all fields and select an image'),
          backgroundColor: Colors.red,
          actions: [
            TextButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: Text('Dismiss'),
            ),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate event creation delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text('Event added successfully!'),
        backgroundColor: Colors.green,
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text('Dismiss'),
          ),
        ],
      ),
    );

    // Navigate back to homepage
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Create Event',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Create New Event",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Fill in the event details below",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: _webImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          Uint8List.fromList(_webImage!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : InkWell(
                        onTap: _pickImage,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Add Event Image',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _eventNameController,
                style: GoogleFonts.inter(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  prefixIcon: Icon(Icons.event, color: Colors.blueAccent),
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter event name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.inter(color: Colors.black87),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description, color: Colors.blueAccent),
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                style: GoogleFonts.inter(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                    style: TextStyle(color: Colors.black87),
                  ),
                  trailing:
                      Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestsController,
                style: GoogleFonts.inter(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Guests',
                  prefixIcon: Icon(Icons.people, color: Colors.blueAccent),
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sponsorsController,
                style: GoogleFonts.inter(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Sponsors',
                  prefixIcon:
                      Icon(Icons.monetization_on, color: Colors.blueAccent),
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'In Person Event',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _isInPersonEvent,
                    onChanged: (value) {
                      setState(() {
                        _isInPersonEvent = value;
                      });
                    },
                    activeColor: Colors.blueAccent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.access_time, color: Colors.blueAccent),
                  title: Text(
                    _selectedTime == null
                        ? 'Select Time'
                        : 'Time: ${_selectedTime!.format(context)} ${DateFormat('a').format(DateTime(2023, 1, 1, _selectedTime!.hour, _selectedTime!.minute))}',
                    style: GoogleFonts.inter(color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.blueAccent),
                  onTap: () => _selectTime(context),
                ),
              ),
              if (_webImage != null) ...[
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.memory(Uint8List.fromList(_webImage!),
                      fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createEvent,
                  style: Theme.of(context).elevatedButtonTheme.style,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'Create Event',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
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
