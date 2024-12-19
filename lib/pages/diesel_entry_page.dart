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

  // Select date for diesel entry
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

  // Fetch the site names dynamically from Firestore
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


  // Submit the diesel entry to Firestore
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
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        // Select Site - Fetching site names dynamically from Firestore
                        const Text(
                          "Select Site",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        FutureBuilder<List<String>>(
                          future: _fetchSiteNames(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('No sites available.');
                            }

                            final siteNames = snapshot.data!;

                            return DropdownButtonFormField<String>(
                              value: _selectedSiteName,
                              items: siteNames
                                  .map<DropdownMenuItem<String>>((site) {
                                return DropdownMenuItem<String>(value: site, child: Text(site));
                              }).toList(),
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
                            );
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
                        ),
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
