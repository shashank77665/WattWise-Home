import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot/bulbcontrol.dart';
import 'package:iot/chart.dart';
import 'package:iot/extra/functions.dart';
import 'package:iot/button.dart';
import 'package:iot/history/analysis.dart';
import 'package:iot/history/data.dart';
import 'package:iot/history/fetch.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, dynamic>? sensorData;
  int loadInWatt = 0;
  int solarCapacityInWatt = 0;
  bool isLoaded = false;
  List<SensorData> data = [];

  void getDataFromFirebase() {
    print('Fetching Started');
    fetchData((data) {
      setState(() {
        sensorData = data;
        isLoaded = true;
        loadInWatt = sensorData?['currentLoad'] * 220;
        solarCapacityInWatt = sensorData?['currentSolarGeneration'] * 24;
        print('${sensorData!['relays']}');
      });
      print('Fetched successfully');
    });
  }

  List<SensorData> getData() {
    return data; // Returns the current list of fetched SensorData
  }

  Future<void> fetchInstance() async {
    var fetchedData = await fetchAllSensorData(context);
    setState(() {
      data = fetchedData
          .map<SensorData>((item) => SensorData.fromMap(item))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchInstance();
    print('Init started');
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(245, 5, 51, 130), // Your AppBar color
        statusBarIconBrightness: Brightness.light, // For white icons
        systemNavigationBarColor:
            Colors.white, // Optional: for bottom navigation
      ),
    );
    getDataFromFirebase();
    print('Init done');
  }

  Future<void> toggleRelay(String relayName, bool value) async {
    final databaseRef = FirebaseDatabase.instance.ref('relays/$relayName');
    try {
      await databaseRef.set(value);
      print('$relayName turned ${value ? "on" : "off"}');
    } catch (e) {
      print('Error updating relay state: $e');
    }
  }

  void handleToggleRelay(String relayName, bool currentValue) {
    toggleRelay(relayName, !currentValue).then((_) {
      setState(() {
        if (sensorData != null && sensorData!['relays'] != null) {
          sensorData!['relays'][relayName] =
              !currentValue; // Update local state
        }
      });
    }).catchError((e) {
      print('Error toggling relay: $e');
    });
  }

  String getFriendlyRelayName(String relayName) {
    // Map relay names to user-friendly names
    switch (relayName) {
      case 'relay1':
        return 'Bulb 1';
      case 'relay2':
        return 'Bulb 2';
      case 'relay3':
        return 'Bulb 3';
      case 'relay4':
        return 'Bulb 4';
      case 'relay5':
        return 'Bulb 5';
      case 'relay6':
        return 'Bulb 6';
      case 'relay7':
        return 'Bulb 7';
      case 'relay8':
        return 'Bulb 8';
      default:
        return relayName; // Default case if no mapping is found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(245, 5, 51, 130),
                const Color.fromARGB(255, 121, 30, 137),
              ],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(245, 5, 51, 130),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(left: 20, bottom: 10),
                      child: const Text(
                        'Current Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatisticsCard(
                          title: '${loadInWatt} W',
                          label: 'Load',
                          icon: Icons.electric_meter,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        _buildStatisticsCard(
                          title: '${solarCapacityInWatt} W',
                          label: 'Generation',
                          icon: Icons.energy_savings_leaf,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (isLoaded && sensorData != null) ...[
                GestureDetector(
                  onTap: () async {
                    print('Starting get Data');
                    await getData();
                    print(data);
                    print('get Data Completed');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Analysis(
                            data: [],
                          ),
                        ));
                    print('Moved Sucessfuly to Analysis Page');
                  },
                  child: CurrentUsageChart(
                    currentLoad: (loadInWatt).toDouble(),
                    currentSolarGeneration: (solarCapacityInWatt).toDouble(),
                  ),
                ),
                const SizedBox(
                    height: 10), // Spacer to add some space after the chart
              ] else
                const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BulbControlPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent, // Makes the background transparent
                    elevation: 10, // Adds elevation
                    shadowColor:
                        Colors.black.withOpacity(0.3), // Soft shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30), // Increased padding
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(245, 5, 51, 130),
                          const Color.fromARGB(255, 121, 30, 137),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(
                          30), // Match the button's border radius
                    ),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 200, // Set a max width
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Light Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: isLoaded && sensorData != null
                      ? GridView.builder(
                          itemCount: sensorData!['relays'].length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemBuilder: (context, index) {
                            final entry =
                                sensorData!['relays'].entries.elementAt(index);
                            return ButtonCard(
                              title: getFriendlyRelayName(entry.key),
                              isOn: entry.value,
                              onPressed: () {
                                handleToggleRelay(entry.key, entry.value);
                              },
                            );
                          },
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
      {required String title, required String label, required IconData icon}) {
    return Container(
      height: 80,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
