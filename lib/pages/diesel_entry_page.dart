import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DieselEntryPage extends StatefulWidget {
  const DieselEntryPage({super.key});

  @override
  _DieselEntryPageState createState() => _DieselEntryPageState();
}

class _DieselEntryPageState extends State<DieselEntryPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _machineIDController = TextEditingController();
  String? _selectedSiteName;
  DateTime? _selectedDate;
  String? userID;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userID = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> submitDieselEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('diesel_entries').add({
          'Amount(in liters)': double.parse(_amountController.text), // Number
          'createdAT': FieldValue.serverTimestamp(), // Timestamp
          'machineID': _machineIDController.text, // String
          'selectSite': _selectedSiteName, // String
          'selectedDate': Timestamp.fromDate(_selectedDate!), // Timestamp
          'userID': userID, // String
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diesel entry added successfully!")),
        );

        // Clear the form after submission
        _amountController.clear();
        _machineIDController.clear();
        setState(() {
          _selectedDate = null;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Diesel Entry",
          style: TextStyle(
            color: Colors.white, // White text for the title
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black, // Black background
        elevation: 0, // Removes shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White arrow
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.teal], // Black to teal gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                color: Colors.black.withOpacity(0.85),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Enter Diesel Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Select Date
                        const Text(
                          "Select Date",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: _selectedDate == null
                                ? "Select Date"
                                : "${_selectedDate!.toLocal()}".split(' ')[0],
                            hintStyle: const TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.teal),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (_selectedDate == null) {
                              return "Please select a date";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Select Site
                        const Text(
                          "Select Site",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          value: _selectedSiteName,
                          items: const [
                            DropdownMenuItem(
                              value: "Gangapur Road",
                              child: Text("Gangapur Road"),
                            ),
                            DropdownMenuItem(
                              value: "Rane Nagar",
                              child: Text("Rane Nagar"),
                            ),
                          ],
                          dropdownColor: Colors.black,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.teal),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedSiteName = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a site";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Machine ID
                        TextFormField(
                          controller: _machineIDController,
                          decoration: InputDecoration(
                            labelText: "Machine ID",
                            labelStyle: const TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.teal),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the machine ID";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Amount
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Amount (in liters)",
                            labelStyle: const TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.teal),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the amount";
                            }
                            if (double.tryParse(value) == null) {
                              return "Please enter a valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        // Submit Button
                        Center(
                          child: ElevatedButton(
                            onPressed: submitDieselEntry,
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white, // White text for the button
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}