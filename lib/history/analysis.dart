import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot/history/data.dart';

class Analysis extends StatefulWidget {
  final List<SensorData> data;
  Analysis({super.key, required this.data});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  DateTime selectedDate = DateTime.now();
// List<SensorData> data = widget.data;
  List<SensorData>? data;
  List<SensorData> dayData = [];
  DailyEnergyStats? selectedDateData;
  bool _isLoading = false;

  DailyEnergyStats calculateDailyEnergyStats(
      List<SensorData> selectedDateData) {
    if (selectedDateData.isEmpty) {
      return DailyEnergyStats(
        todayTotalConsumption: 0,
        todayTotalGeneration: 0,
        maxLoad: 0,
        avgLoad: 0,
        minLoad: 0,
        maxCurrent: 0,
        avgCurrent: 0,
        minCurrent: 0,
      );
    }

    // Calculate total power consumption for the day
    double totalPowerConDay = selectedDateData
        .map((data) => (data.currentLoad * 220) / 60)
        .reduce((a, b) => a + b);

    // Calculate total power generation for the day
    double totalPowerGenDay = selectedDateData
        .map((data) => (data.currentSolarGeneration * 24) / 60)
        .reduce((a, b) => a + b);

    int numberOfTimestamps = selectedDateData.length;

    double todayTotalConsumption =
        (totalPowerConDay * (numberOfTimestamps / 60)) / 1000;
    double todayTotalGeneration =
        (totalPowerGenDay * (numberOfTimestamps / 60)) / 1000;

    // Calculate max, min, and average load
    double maxLoad = selectedDateData
        .map((data) => data.currentLoad.toDouble())
        .reduce((a, b) => a > b ? a : b);

    double minLoad = selectedDateData
        .map((data) => data.currentLoad.toDouble())
        .reduce((a, b) => a < b ? a : b);

    // Calculate total load for average calculation
    double totalLoad = selectedDateData
        .map((data) => data.currentLoad.toDouble())
        .reduce((a, b) => a + b);

    double avgLoad = totalLoad / numberOfTimestamps;

    // Calculate max, min, and average current
    double maxCurrent = selectedDateData
        .map((data) => data.currentSolarGeneration.toDouble())
        .reduce((a, b) => a > b ? a : b);

    double minCurrent = selectedDateData
        .map((data) => data.currentSolarGeneration.toDouble())
        .reduce((a, b) => a < b ? a : b);

    // Calculate total solar generation for average calculation
    double totalCurrent = selectedDateData
        .map((data) => data.currentSolarGeneration.toDouble())
        .reduce((a, b) => a + b);

    double avgCurrent = totalCurrent / numberOfTimestamps;

    return DailyEnergyStats(
      todayTotalConsumption: todayTotalConsumption,
      todayTotalGeneration: todayTotalGeneration,
      maxLoad: maxLoad,
      avgLoad: avgLoad,
      minLoad: minLoad,
      maxCurrent: maxCurrent,
      avgCurrent: avgCurrent,
      minCurrent: minCurrent,
    );
  }

  Future<void> loadScreen() async {
    setState(() {
      _isLoading = true;
    });

    if (data == null) {
      print('Data is null, cannot load screen.');
      setState(() {
        _isLoading = false; // Step 2: End loading if data is null
      });
      return; // Exit if data is not initialized
    }

    dayData = getDataWithinRange(selectedDate, selectedDate);

    setState(() {
      selectedDateData = calculateDailyEnergyStats(dayData);
      _isLoading = false; // Step 2: End loading
    });
  }

  // Future<void> fetchInstance() async {
  //   var fetchedData = await fetchAllSensorData(context);
  //   setState(() {
  //     data = fetchedData
  //         .map<SensorData>((item) => SensorData.fromMap(item))
  //         .toList();
  //   });
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      loadScreen();
    }
  }

  List<SensorData> getDataWithinRange(
      DateTime startingDate, DateTime endingDate) {
    if (data == null) {
      print('Data is null, cannot filter.');
      return []; // Return an empty list if data is null
    }

    DateTime startOfDay =
        DateTime(startingDate.year, startingDate.month, startingDate.day, 0, 0);
    DateTime endOfDay =
        DateTime(endingDate.year, endingDate.month, endingDate.day, 23, 59, 59);

    List<SensorData> filteredData = data!.where((sensorData) {
      return sensorData.timestamp
              .isAfter(startOfDay.subtract(Duration(seconds: 1))) &&
          sensorData.timestamp.isBefore(endOfDay.add(Duration(seconds: 1)));
    }).toList();

    filteredData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return filteredData;
  }

  Future<void> startBuilding() async {
    print('Start Building Started');
    data = widget.data; // Assign the data from the widget
    print(data); // This will show the data if assigned correctly
    print('Data is assigned to data Variable');

    await loadScreen(); // Ensure this is called after data assignment
  }

  @override
  void initState() {
    super.initState();
    startBuilding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 237, 222)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 220, 202, 202),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 70,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)),
                              gradient: LinearGradient(colors: [
                                const Color.fromARGB(255, 10, 78, 134),
                                const Color.fromARGB(255, 11, 113, 160)
                              ])),
                          child: Text(
                            DateFormat('dd').format(selectedDate),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 70,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            gradient: LinearGradient(colors: [
                              const Color.fromARGB(255, 11, 113, 160),
                              Color.fromARGB(255, 10, 78, 134)
                            ]),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('MMM').format(selectedDate),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              Text(
                                DateFormat('yyyy').format(selectedDate),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      loadScreen();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 220, 202, 202),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              alignment: Alignment.center,
              width: double.infinity,
              decoration:
                  BoxDecoration(color: const Color.fromARGB(179, 104, 237, 89)),
              child: Column(
                children: [
                  Text(
                    'Current Date (${DateFormat('dd').format(selectedDate)} ${DateFormat('MMM').format(selectedDate)})',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  _isLoading // Step 3: Conditional UI
                      ? Center(child: CircularProgressIndicator())
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Consumption: ${((selectedDateData?.todayTotalConsumption ?? 0) / 1000).toStringAsFixed(2)} U',
                                    )
                                  ],
                                ),
                                Divider(),
                                Text('Load'),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Max Load : ${selectedDateData?.maxLoad.toStringAsFixed(2) ?? 'N/A'} W'),
                                    Text(
                                        'Avg Load : ${selectedDateData?.avgLoad.toStringAsFixed(2) ?? 'N/A'} W'),
                                    Text(
                                        'Min Load : ${selectedDateData?.minLoad.toStringAsFixed(2) ?? 'N/A'} W'),
                                  ],
                                ),
                              ],
                            ),
                            Divider(color: Colors.black, thickness: 2),
                            Column(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Generation: ${((selectedDateData?.todayTotalGeneration ?? 0) / 1000).toStringAsFixed(2)} U',
                                    )
                                  ],
                                ),
                                Divider(),
                                Text('Solar'),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Max Current : ${selectedDateData?.maxCurrent.toStringAsFixed(2) ?? 'N/A'} A'),
                                    Text(
                                        'Avg Current : ${selectedDateData?.avgCurrent.toStringAsFixed(2) ?? 'N/A'} A'),
                                    Text(
                                        'Min Current : ${selectedDateData?.minCurrent.toStringAsFixed(2) ?? 'N/A'} A'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
