import 'dart:io';
import 'package:event_management_app/constants/colors.dart';
import 'package:event_management_app/containers/custom_headtext.dart';
import 'package:event_management_app/containers/custom_input_form.dart';
import 'package:event_management_app/database.dart';
import 'package:event_management_app/saved_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  FilePickerResult? _filePickerResult;
  Uint8List? _webImagePickerResult;
  bool _isInPersonEvent = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _sponsersController = TextEditingController();

  bool isUploading = false;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    userId = SavedData.getUserId();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to pick date and time
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (pickedDate != null) {
      final TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute);

        setState(() {
          _dateTimeController.text = selectedDateTime.toString();
        });
      }
    }
  }

  // Function to open file picker for selecting images
  void _openFilePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _filePickerResult = result;
      });
    }
  }

  // Function to pick images for web platform
  void pickImageForWeb() async {
    Uint8List? bytesFromPicker = await ImagePickerWeb.getImageAsBytes();
    if (bytesFromPicker != null) {
      setState(() {
        _webImagePickerResult = bytesFromPicker;
      });
    }
  }

  // Function to upload event image to storage
  Future<String?> uploadEventImage() async {
    setState(() {
      isUploading = true;
    });

    try {
      if (_filePickerResult != null) {
        final inputFile = File(_filePickerResult!.files.first.path!);

        // TODO: Implement Firebase/Appwrite storage upload logic here

        print("File uploaded successfully");
        return "uploaded_file_id"; // Replace with actual file ID
      } else {
        print("No file selected");
        return null;
      }
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  // Function to upload image for web
  Future<String?> uploadImageWeb() async {
    try {
      if (_webImagePickerResult != null) {
        // TODO: Implement Firebase/Appwrite storage upload logic for web

        print("Web image uploaded successfully");
        return "uploaded_web_file_id"; // Replace with actual file ID
      } else {
        print("No file selected for web");
        return null;
      }
    } catch (e) {
      print("Error uploading web image: $e");
      return null;
    }
  }

  // Function to create an event
  void _createEvent() async {
    if (_nameController.text.isEmpty ||
        _descController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields are required!")));
      return;
    }

    String? imageUrl;
    if (kIsWeb) {
      imageUrl = await uploadImageWeb();
    } else {
      imageUrl = await uploadEventImage();
    }

    if (imageUrl != null) {
      await createEvent(
        _nameController.text,
        _descController.text,
        imageUrl,
        _locationController.text,
        _dateTimeController.text,
        userId,
        _isInPersonEvent,
        _guestController.text,
        _sponsersController.text,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Event Created!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const CustomHeadText(text: "Create Event"),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                kIsWeb ? pickImageForWeb() : _openFilePicker();
              },
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .3,
                decoration: BoxDecoration(
                    color: kLightGreen, borderRadius: BorderRadius.circular(8)),
                child: _filePickerResult != null
                    ? Image.file(File(_filePickerResult!.files.first.path!),
                        fit: BoxFit.fill)
                    : _webImagePickerResult != null
                        ? Image.memory(_webImagePickerResult!, fit: BoxFit.fill)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined),
                              SizedBox(height: 8),
                              Text(
                                'Add Event Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 20),
            CustomInputForm(
                controller: _nameController,
                label: 'Event Name',
                icon: Icons.event, hint: 'Event Name',),
            const SizedBox(height: 20),
            CustomInputForm(
                controller: _descController,
                hint: 'Event Description',
                label: 'Event Description',
                icon: Icons.description),
            const SizedBox(height: 20),
            CustomInputForm(
                controller: _locationController,
                hint: 'Event Location',
                label: 'Event Location',
                icon: Icons.location_on),
            const SizedBox(height: 20),
            CustomInputForm(
              controller: _dateTimeController,
              hint: 'Event Date & Time',
              label: 'Event Date & Time',
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDateTime(context),
            ),
            const SizedBox(height: 20),
            CustomInputForm(
                controller: _guestController,
                hint: 'Number of Guests',
                label: 'Number of Guests',
                icon: Icons.people),
            const SizedBox(height: 20),
            CustomInputForm(
                controller: _sponsersController,
                hint: 'Event Sponsors',
                label: 'Event Sponsors',
                icon: Icons.business),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createEvent,
              child: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
