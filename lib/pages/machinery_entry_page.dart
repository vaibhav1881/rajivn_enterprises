import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MachineryEntryPage extends StatefulWidget {
  const MachineryEntryPage({Key? key}) : super(key: key);

  @override
  State<MachineryEntryPage> createState() => _MachineryEntryPageState();

}

class _MachineryEntryPageState extends State<MachineryEntryPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Machinery Entry Page'),
    );
  }
}

