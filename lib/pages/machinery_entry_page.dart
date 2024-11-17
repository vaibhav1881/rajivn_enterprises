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
          'imageUrl': _imageFile?.path,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Machinery entry added successfully!")),
        );

        // Clear form after submission
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Machinery Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Removed the teal color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Changed to white
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
                    _buildFancyTextField(_startHourController, "Start Hour", Icons.access_time),
                    const SizedBox(height: 20),
                    _buildFancyTextField(_stopHourController, "Stop Hour", Icons.access_time_outlined),
                    const SizedBox(height: 20),
                    _buildImagePickerButton(),
                    const SizedBox(height: 10), // Reduced space
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

  Widget _buildImagePickerButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text("Pick Image", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal, // Teal color
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
          backgroundColor: Colors.teal, // Teal color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        ),
      ),
    );
  }
}
