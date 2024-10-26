import 'package:cloud_firestore/cloud_firestore.dart';

//Get Data for Statictics HomePage
Future<List<Map<String, dynamic>>> getSensorDataByDate(DateTime date) async {
  // Initialize Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Start and end of the day
  DateTime startOfDay = DateTime(date.year, date.month, date.day);
  DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

  // Query to fetch documents within the day
  QuerySnapshot querySnapshot = await firestore
      .collection('sensorData')
      .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
      .where('timestamp', isLessThanOrEqualTo: endOfDay)
      .get();

  // Process results
  List<Map<String, dynamic>> sensorData = querySnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();

  return sensorData;
}

Future<List<Map<String, dynamic>>> getSensorDataBetweenDates(
    DateTime startDate, DateTime endDate) async {
  // Initialize Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Start and end of the specified range
  DateTime startOfDay =
      DateTime(startDate.year, startDate.month, startDate.day);
  DateTime endOfDay =
      DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

  // Query to fetch documents within the specified date range
  QuerySnapshot querySnapshot = await firestore
      .collection('sensorData')
      .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
      .where('timestamp', isLessThanOrEqualTo: endOfDay)
      .get();

  // Process results and convert to list of maps
  List<Map<String, dynamic>> sensorData = querySnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();

  return sensorData;
}

Future<Map<String, double>> getTotalConsumptionAndGenerationTillDate() async {
  // Initialize Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query to fetch all documents in 'sensorData' collection
  QuerySnapshot querySnapshot = await firestore.collection('sensorData').get();

  // Initialize totals
  double totalConsumption = 0;
  double totalGeneration = 0;

  // Process each document in the collection
  for (var doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Assuming 'currentLoad' and 'currentSolarGeneration' are in watts
    if (data.containsKey('currentLoad') &&
        data.containsKey('currentSolarGeneration')) {
      double currentLoad = data['currentLoad'] ?? 0; // Fallback to 0 if null
      double currentSolarGeneration =
          data['currentSolarGeneration'] ?? 0; // Fallback to 0 if null

      // Convert power to energy in kWh (assuming data is for each minute)
      double loadKWh =
          (currentLoad / 1000) * (1 / 60); // kWh for 1-minute interval
      double generationKWh = (currentSolarGeneration / 1000) *
          (1 / 60); // kWh for 1-minute interval

      // Accumulate totals
      totalConsumption += loadKWh;
      totalGeneration += generationKWh;
    }
  }

  // Return totals in a map
  return {
    'totalConsumptionTillDate': totalConsumption, // Total consumption in kWh
    'totalGenerationTillDate': totalGeneration, // Total generation in kWh
  };
}
