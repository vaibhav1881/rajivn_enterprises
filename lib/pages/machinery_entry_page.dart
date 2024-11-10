import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MachineryEntryPage extends StatefulWidget {
  const MachineryEntryPage({super.key});

  @override
  State<MachineryEntryPage> createState() => _MachineryEntryPageState();
}

class _MachineryEntryPageState extends State<MachineryEntryPage> {
  final TextEditingController _driverIDController = TextEditingController();
  final TextEditingController _machineIDController = TextEditingController();
  final TextEditingController _startHourController = TextEditingController();
  final TextEditingController _stopHourController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  String? _selectedMachineType = 'Bucket'; // Default machine type
  String? _selectedSiteName;
  String? userID;
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userID = FirebaseAuth.instance.currentUser?.uid; // Automatically set user ID
  }

  // Method to request storage permission
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image picking
    } else if (status.isDenied) {
      // Show an alert or message if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is denied")),
      );
    } else if (status.isPermanentlyDenied) {
      // Show an alert directing the user to settings if permission is permanently denied
      openAppSettings();
    }
  }


  // Method to pick an image from gallery
  Future<void> _pickImage() async {
    await requestStoragePermission();

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      // If no image was picked, show an alert
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image was picked")),
      );
    }
  }


  // Method to show date and time picker for selecting start and stop hours
  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) {
            _startHourController.text = "${selectedDateTime.toLocal()}".split(' ')[0] + ' ' + "${selectedDateTime.hour}:${selectedDateTime.minute}";
          } else {
            _stopHourController.text = "${selectedDateTime.toLocal()}".split(' ')[0] + ' ' + "${selectedDateTime.hour}:${selectedDateTime.minute}";
          }
        });
      }
    }
  }

  // Fetch site names from Firestore (assuming 'sites' collection exists in Firestore)
  Future<List<String>> _fetchSiteNames() async {
    final snapshot = await FirebaseFirestore.instance.collection('sites').get();
    return snapshot.docs.map((doc) => doc['siteName'] as String).toList();
  }

  Future<void> submitMachineryEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('machinery_entries').add({
          'userId': userID,
          'driverID': _driverIDController.text,
          'machineID': _machineIDController.text,
          'machineType': _selectedMachineType,
          'siteName': _selectedSiteName,
          'startHour': Timestamp.fromDate(DateTime.parse(_startHourController.text)),
          'stopHour': Timestamp.fromDate(DateTime.parse(_stopHourController.text)),
          'imageUrl': _imageFile?.path, // Image file path or URL (you can upload the image to Firebase Storage)
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Machinery entry added successfully!")),
        );

        // Clear the form after submission
        _driverIDController.clear();
        _machineIDController.clear();
        _startHourController.clear();
        _stopHourController.clear();
        _imageController.clear();
        setState(() {
          _imageFile = null;
          _selectedMachineType = 'Bucket'; // Reset to default
          _selectedSiteName = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding entry: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _driverIDController.dispose();
    _machineIDController.dispose();
    _startHourController.dispose();
    _stopHourController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Machinery Entry"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<String>>(
          future: _fetchSiteNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No sites available.'));
            }

            final siteNames = snapshot.data!;

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _driverIDController,
                    decoration: const InputDecoration(labelText: "Driver ID"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the driver ID";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _machineIDController,
                    decoration: const InputDecoration(labelText: "Machine ID"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the machine ID";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedMachineType,
                    items: ['Bucket', 'Breaker']
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMachineType = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Machine Type"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedSiteName,
                    items: siteNames
                        .map((siteName) => DropdownMenuItem(
                      value: siteName,
                      child: Text(siteName),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSiteName = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Site Name"),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _startHourController,
                    decoration: const InputDecoration(
                      labelText: "Start Hour",
                      hintText: "yyyy-MM-dd HH:mm:ss",
                    ),
                    readOnly: true,
                    onTap: () => _selectDateTime(context, true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select the start hour";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _stopHourController,
                    decoration: const InputDecoration(
                      labelText: "Stop Hour",
                      hintText: "yyyy-MM-dd HH:mm:ss",
                    ),
                    readOnly: true,
                    onTap: () => _selectDateTime(context, false),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please select the stop hour";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Pick Image"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: submitMachineryEntry,
                    child: const Text("Submit Entry"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
