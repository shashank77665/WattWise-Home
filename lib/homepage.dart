import 'package:flutter/material.dart';
import 'package:iot/functions.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Map<String, int>? SensorData;
  bool isLoaded = false;

  void getDataFromFirebase() async {
    print('fetching Started');
    try {
      final data = await fetchData();
      fetchDatatoFirebase();
      setState(() {
        SensorData = data;
        isLoaded = true;

        print('$SensorData');
      });

      print('fteched sucesfully');
    } catch (e) {
      print('Ftechfailed $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init started');
    getDataFromFirebase();
    print('init done');
    print('$SensorData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: isLoaded
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Current Load : ${SensorData!['currentLoad']}'),
                        Text(
                            'Current Generation : ${SensorData!['currentSolarGeneration']}'),
                      ],
                    )
                  : CircularProgressIndicator())),
    );
  }
}
