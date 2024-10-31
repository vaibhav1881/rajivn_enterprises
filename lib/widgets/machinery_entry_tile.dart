import 'package:flutter/material.dart';

class MachineryEntryTile extends StatelessWidget {
  final String machineryName;
  final String siteName;
  final String driverName;
  final String startTime;
  final String endTime; 

  const MachineryEntryTile({super.key, 
    required this.machineryName,
    required this.siteName,
    required this.driverName,
    required this.startTime,
    required this.endTime, required entryId, required entryData, required String userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(machineryName),
          Text(siteName),
          Text(driverName),
          Text(startTime),
          Text(endTime),
        ],
      ),
    );
  }
} 
  