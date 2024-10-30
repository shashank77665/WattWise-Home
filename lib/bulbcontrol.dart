import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot/button.dart';
import 'package:iot/extra/functions.dart';

class BulbControlPage extends StatefulWidget {
  const BulbControlPage({Key? key}) : super(key: key);

  @override
  _BulbControlPageState createState() => _BulbControlPageState();
}

class _BulbControlPageState extends State<BulbControlPage> {
  Map<String, dynamic>? sensorData;
  bool isLoaded = false;

  void getDataFromFirebase() {
    print('Fetching bulb data started');
    fetchData((data) {
      setState(() {
        sensorData = data;
        isLoaded = true;
        print('${sensorData!['relays']}');
      });
      print('Fetched bulb data successfully');
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(245, 5, 51, 130),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
      ),
    );
    getDataFromFirebase();
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

        // Logic to turn off other groups based on the current toggle
        if (relayName.startsWith('relay') && relayName == 'relay5') {
          // If relay5 is toggled off while relay1-4 are on, turn off all
          if (!sensorData!['relays'][relayName] &&
              sensorData!['relays']['relay1'] == true) {
            toggleAllBulbs(false);
          }
        } else if (relayName.startsWith('relay') && relayName == 'relay1') {
          // If all are turned off, turn off group 1-4 and 5-8
          if (!sensorData!['relays'][relayName] &&
              sensorData!['relays'].values.every((v) => !v)) {
            toggleGroup1To4(false);
            toggleGroup5To8(false);
          }
        }
      });
    }).catchError((e) {
      print('Error toggling relay: $e');
    });
  }

  void toggleAllBulbs(bool value) {
    sensorData!['relays'].forEach((key, currentValue) {
      toggleRelay(key, value);
      sensorData!['relays'][key] = value; // Update local state
    });
    setState(() {}); // Refresh the UI
  }

  void toggleGroup1To4(bool value) {
    for (int i = 1; i <= 4; i++) {
      String relayName = 'relay$i';
      toggleRelay(relayName, value);
      if (sensorData!['relays'].containsKey(relayName)) {
        sensorData!['relays'][relayName] = value; // Update local state
      }
    }
    setState(() {}); // Refresh the UI
  }

  void toggleGroup5To8(bool value) {
    for (int i = 5; i <= 8; i++) {
      String relayName = 'relay$i';
      toggleRelay(relayName, value);
      if (sensorData!['relays'].containsKey(relayName)) {
        sensorData!['relays'][relayName] = value; // Update local state
      }
    }
    setState(() {}); // Refresh the UI
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
      appBar: AppBar(
        title: Text(
          'Light Control',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(255, 5, 51, 130),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 119, 12, 138),
              const Color.fromARGB(255, 119, 12, 138),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: isLoaded
                ? sensorData != null
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Bulb Control',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Add toggle buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => toggleAllBulbs(true),
                                  child: const Text('Turn All On'),
                                ),
                                ElevatedButton(
                                  onPressed: () => toggleAllBulbs(false),
                                  child: const Text('Turn All Off'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => toggleGroup1To4(true),
                                  child: const Text('Turn 1-4 On'),
                                ),
                                ElevatedButton(
                                  onPressed: () => toggleGroup1To4(false),
                                  child: const Text('Turn 1-4 Off'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => toggleGroup5To8(true),
                                  child: const Text('Turn 5-8 On'),
                                ),
                                ElevatedButton(
                                  onPressed: () => toggleGroup5To8(false),
                                  child: const Text('Turn 5-8 Off'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Create a GridView for ButtonCards instead of a Column
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemCount: sensorData!['relays'].length,
                                itemBuilder: (context, index) {
                                  final entry = sensorData!['relays']
                                      .entries
                                      .elementAt(index);
                                  return ButtonCard(
                                    title: getFriendlyRelayName(
                                        entry.key), // Use friendly name
                                    isOn: entry.value,
                                    onPressed: () {
                                      handleToggleRelay(entry.key, entry.value);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Text(
                        'Sensor data not available',
                        style: TextStyle(color: Colors.white),
                      )
                : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
