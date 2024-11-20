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
  final TextEditingController _selectedHourController = TextEditingController();
  String? _selectedMachineType = 'Bucket'; // Default machine type
  String? _selectedSiteName;
  String? _selectedHour;
  String? userID;
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    userID = FirebaseAuth.instance.currentUser?.uid; // Automatically set user ID
  }

  // Request storage permission for image picking
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image picking
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is denied")),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    await requestStoragePermission();

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image was picked")),
      );
    }
  }

  // Select date for machinery entry
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Fetch the site names from Firestore
  // Fetch the site names dynamically from Firestore
  Future<List<String>> _fetchSiteNames() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('sites').get();
      // Check if siteName field exists and map to the list
      return snapshot.docs.map((doc) {
        // Try accessing the siteName field, if not found fallback to 'Unknown Site'
        if (doc.data().containsKey('siteName')) {
          return doc['siteName'] as String;
        } else if (doc.data().containsKey('name')) {
          return doc['name'] as String;  // Fallback to 'name' if 'siteName' is missing
        } else {
          return 'Unknown Site';  // Fallback if no siteName or name exists
        }
      }).toList();
    } catch (e) {
      print("Error fetching site names: $e");
      return [];
    }
  }


  // Submit the machinery entry to Firestore
  Future<void> submitMachineryEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('machinery_entry').add({
          'userId': userID,
          'driverID': _driverIDController.text,
          'machineID': _machineIDController.text,
          'machineType': _selectedMachineType,
          'siteName': _selectedSiteName,
          'selectedDate': _selectedDate, // Store selected date
          'selectedHour': _selectedHour, // Store selected hour (Start Hour or Stop Hour)
          'enteredHour': _selectedHourController.text, // Store entered hour
          'imageUrl': _imageFile?.path, // Store image URL
          'createdAt': FieldValue.serverTimestamp(), // Timestamp when entry is created
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Machinery entry added successfully!")),
        );

        // Clear form after submission
        _driverIDController.clear();
        _machineIDController.clear();
        _selectedHourController.clear();
        setState(() {
          _imageFile = null;
          _selectedMachineType = 'Bucket'; // Reset to default
          _selectedSiteName = null;
          _selectedDate = null;
          _selectedHour = null;
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
    _selectedHourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Machinery Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFancyTextField(_driverIDController, "Driver ID", Icons.drive_eta),
                    const SizedBox(height: 20),
                    _buildFancyTextField(_machineIDController, "Machine ID", Icons.directions_car),
                    const SizedBox(height: 20),
                    _buildFancyDropdown("Machine Type", ['Bucket', 'Breaker'], _selectedMachineType, (value) {
                      setState(() {
                        _selectedMachineType = value;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildFancyDropdown("Site Name", siteNames, _selectedSiteName, (value) {
                      setState(() {
                        _selectedSiteName = value;
                      });
                    }),
                    const SizedBox(height: 20),
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildHourDropdown(),
                    if (_selectedHour != null) ...[
                      const SizedBox(height: 20),
                      _buildManualHourTextField(),
                    ],
                    const SizedBox(height: 20),
                    _buildImagePickerButton(),
                    const SizedBox(height: 10),
                    _buildSexySubmitButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFancyTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  Widget _buildFancyDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          dropdownColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: _selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : ''),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Select Date",
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
            filled: true,
            fillColor: Colors.grey[850],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: "Select Hour",
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedHour,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          onChanged: (String? newValue) {
            setState(() {
              _selectedHour = newValue;
              _selectedHourController.clear();
            });
          },
          items: <String>['Start Hour', 'Stop Hour']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          dropdownColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildManualHourTextField() {
    return TextFormField(
      controller: _selectedHourController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Enter Hour",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.access_time, color: Colors.teal),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the hour';
        }
        return null;
      },
    );
  }

  Widget _buildImagePickerButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text("Pick Image", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildSexySubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: submitMachineryEntry,
        child: const Text("Submit Entry", style: TextStyle(color: Colors.white, fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
      ),
    );
  }
}
