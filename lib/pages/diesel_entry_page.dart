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
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _refillTimeController = TextEditingController();
  String? userID;
  DateTime? _selectedDateTime; // To store the selected date and time

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    userID = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // Show the Date Picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Show the Time Picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        // Combine the selected date and time
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // Update the controller with formatted date-time
          _refillTimeController.text =
              "${_selectedDateTime!.toLocal()}".split(' ')[0] + ' ' + "${_selectedDateTime!.hour}:${_selectedDateTime!.minute}";
        });
      }
    }
  }

  Future<void> submitDieselEntry() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('diesel_entries').add({
          'userId': userID,
          'amount': double.parse(_amountController.text),
          'machineID': _machineIDController.text,
          'refillTime': Timestamp.fromDate(_selectedDateTime!),
          'siteName': _siteNameController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diesel entry added successfully!")),
        );

        // Clear the form after submission
        _amountController.clear();
        _machineIDController.clear();
        _siteNameController.clear();
        _refillTimeController.clear();
        setState(() {
          _selectedDateTime = null; // Reset date-time
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
    _amountController.dispose();
    _machineIDController.dispose();
    _siteNameController.dispose();
    _refillTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diesel Entry"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount (in liters)"),
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
              TextFormField(
                controller: _refillTimeController,
                decoration: const InputDecoration(
                  labelText: "Refill Time",
                  hintText: "yyyy-MM-dd HH:mm:ss",
                ),
                readOnly: true, // Makes the field non-editable directly
                onTap: () {
                  _selectDateTime(context); // Trigger the date-time picker
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select the refill time";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _siteNameController,
                decoration: const InputDecoration(labelText: "Site Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the site name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitDieselEntry,
                child: const Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
