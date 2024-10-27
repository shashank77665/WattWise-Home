import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iot/energycalculation.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  DateTime date = DateTime.now();
  List<Map<String, dynamic>>? data;
  List<Map<String, dynamic>>? thisMonth;
  List<Map<String, dynamic>>? overall;
  late int maxCon;
  late int maxSolar;
  late double avgCon;
  late double avgSolar;
  late int minCon;
  late int minSolar;
  double totalConDay = 0;
  double totalGenDay = 0;
  bool isLoading = true;
  late int totalConThisMonth;
  late int totalGenThisMonth;

  void calculateTotalDayConsumptionAndGeneration() {
    totalConDay = 0; // Reset total consumption
    totalGenDay = 0; // Reset total generation

    double totalPowerConDay = 0;
    double totalPowerGenDay = 0;

    // Initialize numberOfTimestamps to the length of data
    int numberOfTimestamps = data != null ? data!.length : 0;

    if (numberOfTimestamps > 0) {
      for (var entry in data!) {
        // Convert current load and solar generation to power in watts
        totalPowerConDay += (entry['currentLoad'] * 220) / 60;
        totalPowerGenDay += (entry['currentSolarGeneration'] * 24) / 60;
      }

      // Calculate total consumption and generation based on data length
      print('totalPowerConDay : $totalPowerConDay');
      totalConDay = (totalPowerConDay * (numberOfTimestamps / 60)) /
          1000; // Convert to kWh
      totalGenDay = (totalPowerGenDay * (numberOfTimestamps / 60)) /
          1000; // Convert to kWh
    }
  }

  void MapMaxAvgMin() {
    if (data != null && data!.isNotEmpty) {
      maxCon = data![0]['currentSolarGeneration'];
      maxSolar = data![0]['currentLoad'];

      minCon = maxCon; // Initialize minCon to the first value
      minSolar = maxSolar; // Initialize minSolar to the first value

      double totalGen = 0;
      double totalSolar = 0;

      for (var entry in data!) {
        // Calculate total for average
        totalGen += entry['currentSolarGeneration'];
        totalSolar += entry['currentLoad'];

        // Calculate maximum values
        if (entry['currentSolarGeneration'] > maxCon) {
          maxCon = entry['currentSolarGeneration'];
        }
        if (entry['currentLoad'] > maxSolar) {
          maxSolar = entry['currentLoad'];
        }

        // Calculate minimum values
        if (entry['currentSolarGeneration'] < minCon) {
          minCon = entry['currentSolarGeneration'];
        }
        if (entry['currentLoad'] < minSolar) {
          minSolar = entry['currentLoad'];
        }
      }

      // Calculate average values
      avgCon = totalGen / data!.length;
      avgSolar = totalSolar / data!.length;
    } else {
      // Handle case when there's no data
      maxCon = 0;
      maxSolar = 0;
      avgCon = 0;
      avgSolar = 0;
      minCon = 0;
      minSolar = 0;
    }
  }

  void getCurrentDateData() async {
    // Fetch data based on the current date

    setState(() {
      isLoading = true;
    });
    data = await getSensorDataByDate(context, date);
    MapMaxAvgMin();
    calculateTotalDayConsumptionAndGeneration();

    setState(() {
      isLoading = false;
    });
  }

  void getThisMonthData() async {
    DateTime startDate = DateTime(date.year, date.month, 1);
    setState(() {
      isLoading = true;
    });
    thisMonth = await getSensorDataByDateRange(context, startDate, date);
    setState(() {
      isLoading = false;
    });
  }

  void getOverallData() async {
    DateTime startDate = DateTime(2024, 1, 1);
    setState(() {
      isLoading = true;
    });
    thisMonth = await getSensorDataByDateRange(context, startDate, date);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate; // Update the date
      });
      refresh();
    }
  }

  void refresh() async {
    setState(() {});
    getCurrentDateData();
    getThisMonthData();
    getOverallData();
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 220, 202, 202),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.arrow_back),
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Container(
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
                                            const Color.fromARGB(
                                                255, 10, 78, 134),
                                            const Color.fromARGB(
                                                255, 11, 113, 160)
                                          ])),
                                      child: Text(
                                        DateFormat('dd').format(date),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
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
                                          const Color.fromARGB(
                                              255, 11, 113, 160),
                                          Color.fromARGB(255, 10, 78, 134)
                                        ]),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            DateFormat('MMM').format(date),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            DateFormat('yyyy').format(date),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                refresh();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 220, 202, 202),
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.refresh),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(179, 104, 237, 89)),
                        child: Column(
                          children: [
                            Text(
                              'Current Date (${DateFormat('dd').format(date)} ${DateFormat('MMM').format(date)})',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                            'Consumption: ${(totalConDay / 1000).toStringAsFixed(2)} U'),

                                        //      Text('${totalCon.toStringAsFixed(2)} U')
                                      ],
                                    ),
                                    Divider(),
                                    Text('Load'),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Max Load : ${(maxCon * 220).toString()} W'),
                                        Text(
                                            'Avg Load : ${(avgCon * 220).toStringAsFixed(0)} W'),
                                        Text(
                                            'Min Load : ${(minCon * 220).toString()} W'),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.black,
                                  thickness: 2,
                                ),
                                Column(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                            'Generation ${(totalGenDay / 1000).toStringAsFixed(2)} U'),
                                        //    Text('${totalGen.toStringAsFixed(2)} U')
                                      ],
                                    ),
                                    Divider(),
                                    Text('Solar'),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Max Current : $maxSolar A'),
                                        Text(
                                            'Avg Current : ${avgSolar.toStringAsFixed(0)} A'),
                                        Text('Min Current : $minSolar A'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(179, 182, 242, 175)),
                        child: Column(
                          children: [
                            Text(
                              'This Month (${DateFormat('MMM').format(date)})',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('Total Consumption : '),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Max Consumed on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Avg Consumption : '),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Least Consumed on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Total Generated : '),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Max Generated on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Avg Generation : '),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Least Generated on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(179, 171, 236, 163)),
                        child: Column(
                          children: [
                            Text(
                              'This Year (till ${DateFormat('yyy').format(date)} )',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('Total Consumption : '),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Max Consumed on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Avg Consumption : '),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Least Consumed on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Total Generated : '),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Max Generated on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Avg Generation : '),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Least Generated on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(179, 225, 247, 222)),
                        child: Column(
                          children: [
                            Text(
                              'Overall (till ${DateFormat('dd').format(date)} ${DateFormat('MMM').format(date)})',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('Total Consumption : '),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Max Consumed on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Avg Consumption : '),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Least Consumed on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Total Generated : '),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Max Generated on : '),
                                            Text('Reading')
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Avg Generation : '),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Text('Least Generated on : '),
                                            Text('Reading')
                                          ],
                                        )
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
                )),
    );
  }
}
