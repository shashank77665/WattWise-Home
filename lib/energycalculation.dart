// import 'package:cloud_firestore/cloud_firestore.dart';

// //Get Data for Statictics HomePage
// Future<List<Map<String, dynamic>>> getSensorDataByDate(DateTime date) async {
//   // Initialize Firestore instance
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // Start and end of the day
//   DateTime startOfDay = DateTime(date.year, date.month, date.day);
//   DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

//   // Query to fetch documents within the day
//   QuerySnapshot querySnapshot = await firestore
//       .collection('sensorData')
//       .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
//       .where('timestamp', isLessThanOrEqualTo: endOfDay)
//       .get();

//   // Process results
//   List<Map<String, dynamic>> sensorData = querySnapshot.docs
//       .map((doc) => doc.data() as Map<String, dynamic>)
//       .toList();

//   return sensorData;
// }

// // Get Data for Statistics HomePage within a specified date range
// Future<List<Map<String, dynamic>>> getSensorDataByDateRange(
//     DateTime startDate, DateTime endDate) async {
//   // Initialize Firestore instance
//   FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // Ensure the end date includes the entire day
//   DateTime endOfRange =
//       DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

//   // Query to fetch documents within the date range
//   QuerySnapshot querySnapshot = await firestore
//       .collection('sensorData')
//       .where('timestamp', isGreaterThanOrEqualTo: startDate)
//       .where('timestamp', isLessThanOrEqualTo: endOfRange)
//       .get();

//   // Process results
//   List<Map<String, dynamic>> sensorData = querySnapshot.docs
//       .map((doc) => doc.data() as Map<String, dynamic>)
//       .toList();

//   return sensorData;
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Function to fetch all sensor data from Firestore
Future<List<Map<String, dynamic>>> fetchAllSensorData(
    BuildContext context) async {
  // Initialize Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Query to fetch all documents in the sensorData collection with a timeout
    QuerySnapshot querySnapshot = await firestore
        .collection('sensorData')
        .get()
        .timeout(Duration(seconds: 30));

    // Process results
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  } catch (e) {
    // Show Snackbar indicating failure
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to fetch sensor data: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    return []; // Return an empty list in case of failure
  }
}

// Get Data for Statistics HomePage for a specific date
Future<List<Map<String, dynamic>>> getSensorDataByDate(
    BuildContext context, DateTime date) async {
  // Fetch all sensor data
  List<Map<String, dynamic>> allSensorData = await fetchAllSensorData(context);

  // Filter the data for the specified date
  return allSensorData.where((data) {
    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
    return timestamp.year == date.year &&
        timestamp.month == date.month &&
        timestamp.day == date.day;
  }).toList();
}

// Get Data for Statistics HomePage within a specified date range
Future<List<Map<String, dynamic>>> getSensorDataByDateRange(
    BuildContext context, DateTime startDate, DateTime endDate) async {
  // Fetch all sensor data
  List<Map<String, dynamic>> allSensorData = await fetchAllSensorData(context);

  // Filter the data for the specified date range
  return allSensorData.where((data) {
    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
    return timestamp.isAfter(startDate
            .subtract(Duration(days: 1))) && // To include the start date
        timestamp.isBefore(
            endDate.add(Duration(days: 1))); // To include the end date
  }).toList();
}
