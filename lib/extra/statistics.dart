// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Import intl for date formatting
// import 'package:iot/extra/energycalculation.dart';

// class StatisticsPage extends StatefulWidget {
//   const StatisticsPage({super.key});

//   @override
//   State<StatisticsPage> createState() => _StatisticsPageState();
// }

// class _StatisticsPageState extends State<StatisticsPage> {
//   List<Map<String, dynamic>>? data;
//   late int maxCon;
//   late int maxSolar;
//   late double avgCon;
//   late double avgSolar;
//   late int minCon;
//   late int minSolar;
//   double totalCon = 0;
//   double totalGen = 0;
//   DateTime date = DateTime.now();
//   bool isLoading = true;
//   int totalMonthCon = 0;
//   int totalMonthGeneration = 0;

//   void calculateTotals() async {
//     // Fetch data from Firestore
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('sensorData').get();
//     if (snapshot.docs.isNotEmpty) {
//       double totalConsumptionKWh = 0;
//       double totalGenerationKWh = 0;

//       for (var doc in snapshot.docs) {
//         double currentLoad = doc['currentLoad'] ?? 0; // Current in amps
//         double currentSolarGeneration =
//             doc['currentSolarGeneration'] ?? 0; // Current in amps

//         // Convert current to power in watts
//         double powerConsumption = 220 * currentLoad; // in watts
//         double powerGeneration = 220 * currentSolarGeneration; // in watts

//         // Calculate energy (kWh) for a 24-hour period
//         double consumptionKWh = (powerConsumption / 1000) * 24;
//         double generationKWh = (powerGeneration / 1000) * 24;

//         // Accumulate total consumption
//         totalConsumptionKWh += consumptionKWh;

//         // Accumulate total generation if condition is met
//         if (currentSolarGeneration > 1) {
//           totalGenerationKWh += generationKWh;
//         }
//       }

//       // Set state or variables to store these totals
//       setState(() {
//         totalCon = totalConsumptionKWh; // Total consumption in kWh
//         totalGen = totalGenerationKWh; // Total generation in kWh
//       });
//     } else {
//       // Handle the case when there's no data
//       setState(() {
//         totalCon = 0;
//         totalGen = 0;
//       });
//     }
//   }

//   void MapMaxAvgMin() {
//     if (data != null && data!.isNotEmpty) {
//       maxCon = data![0]['currentSolarGeneration'];
//       maxSolar = data![0]['currentLoad'];

//       minCon = maxCon; // Initialize minCon to the first value
//       minSolar = maxSolar; // Initialize minSolar to the first value

//       double totalGen = 0;
//       double totalSolar = 0;

//       for (var entry in data!) {
//         // Calculate total for average
//         totalGen += entry['currentSolarGeneration'];
//         totalSolar += entry['currentLoad'];

//         // Calculate maximum values
//         if (entry['currentSolarGeneration'] > maxCon) {
//           maxCon = entry['currentSolarGeneration'];
//         }
//         if (entry['currentLoad'] > maxSolar) {
//           maxSolar = entry['currentLoad'];
//         }

//         // Calculate minimum values
//         if (entry['currentSolarGeneration'] < minCon) {
//           minCon = entry['currentSolarGeneration'];
//         }
//         if (entry['currentLoad'] < minSolar) {
//           minSolar = entry['currentLoad'];
//         }
//       }

//       // Calculate average values
//       avgCon = totalGen / data!.length;
//       avgSolar = totalSolar / data!.length;
//     } else {
//       // Handle case when there's no data
//       maxCon = 0;
//       maxSolar = 0;
//       avgCon = 0;
//       avgSolar = 0;
//       minCon = 0;
//       minSolar = 0;
//     }
//   }

//   void getCurrentDateData() async {
//     // Fetch data based on the current date

//     setState(() {
//       isLoading = false;
//     });
//     data = await getSensorDataByDate(context, date);
//     MapMaxAvgMin();
//     calculateTotals();

//     setState(() {
//       isLoading = true;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     getCurrentDateData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Format the date to a readable string
//     String formattedDate = DateFormat('yyyy-MM-dd').format(date);

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: 50,
//                 decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 69, 148, 212),
//                     borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(15),
//                         bottomRight: Radius.circular(15))),
//                 alignment: Alignment.center,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   mainAxisSize: MainAxisSize.max,
//                   children: [
//                     Text(
//                       'Statistics',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.center,
//                     )
//                   ],
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(left: 20, top: 20),
//                     height: 40,
//                     width: 40,
//                     decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 220, 202, 202),
//                         borderRadius: BorderRadius.circular(10)),
//                     child: const Icon(Icons.arrow_back),
//                   ),
//                 ),
//               ),
//               Text(
//                 DateFormat.MMMM().format(
//                     DateTime.now()), // This will print the current month name
//                 style: TextStyle(fontSize: 20),
//               ),
//               Container(
//                 color: Colors.amber,
//                 child: Column(
//                   children: [
//                     Text('Total Consumption : $totalMonthCon'),
//                     Text('Total Generation : $totalMonthGeneration')
//                   ],
//                 ),
//               ),
//               Divider(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Column(
//                     children: [
//                       Text('Consumption'),
//                       Divider(),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Max : '),
//                           Text('Avg : '),
//                           Text('Min : ')
//                         ],
//                       )
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       Text('Generation'),
//                       Divider(),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Max : '),
//                           Text('Avg : '),
//                           Text('Min : ')
//                         ],
//                       )
//                     ],
//                   )
//                 ],
//               ),
//               Divider(
//                 color: Colors.black,
//                 thickness: 2,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         date =
//                             date.subtract(Duration(days: 1)); // Update the date
//                         getCurrentDateData(); // Fetch new data
//                       });
//                     },
//                     child: Icon(Icons.arrow_back_ios_new_sharp),
//                   ),
//                   GestureDetector(
//                     onTap: () async {
//                       // Show date picker
//                       DateTime? selectedDate = await showDatePicker(
//                         context: context,
//                         initialDate:
//                             date, // Set the initial date to the currently selected date
//                         firstDate: DateTime(2000), // Set the minimum date
//                         lastDate:
//                             DateTime.now(), // Set the maximum date to today
//                       );

//                       // If a date is selected, update the state
//                       if (selectedDate != null && selectedDate != date) {
//                         setState(() {
//                           date = selectedDate; // Update the selected date
//                         });

//                         // Fetch data for the new selected date
//                         getCurrentDateData();
//                       }
//                     },
//                     child: Text(
//                       formattedDate,
//                       style: TextStyle(
//                           fontSize: 18, color: Colors.blue), // Style the text
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         date = date.add(Duration(days: 1)); // Update the date
//                         getCurrentDateData(); // Fetch new data
//                       });
//                     },
//                     child: Icon(Icons.arrow_forward_ios_sharp),
//                   ),
//                 ],
//               ),
//               isLoading
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Column(
//                           children: [
//                             Column(
//                               children: [
//                                 Text('Consumption'),
//                                 Text('${totalCon.toStringAsFixed(2)} U')
//                               ],
//                             ),
//                             Divider(),
//                             Text('Load'),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                     'Max Load : ${(maxCon * 220).toString()} W'),
//                                 Text(
//                                     'Avg Load : ${(avgCon * 220).toStringAsFixed(0)} W'),
//                                 Text(
//                                     'Min Load : ${(minCon * 220).toString()} W'),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Divider(
//                           color: Colors.black,
//                           thickness: 2,
//                         ),
//                         Column(
//                           children: [
//                             Column(
//                               children: [
//                                 Text('Generation'),
//                                 Text('${totalGen.toStringAsFixed(2)} U')
//                               ],
//                             ),
//                             Divider(),
//                             Text('Solar'),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Max Current : $maxSolar A'),
//                                 Text(
//                                     'Avg Current : ${avgSolar.toStringAsFixed(0)} A'),
//                                 Text('Min Current : $minSolar A'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     )
//                   : CircularProgressIndicator(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
