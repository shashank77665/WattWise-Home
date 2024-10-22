import 'package:firebase_database/firebase_database.dart';

void fetchData(Function(Map<String, dynamic>?) onDataUpdated) {
  final databaseRef = FirebaseDatabase.instance.ref();

  databaseRef.onValue.listen((event) {
    final snapshot = event.snapshot;
    if (snapshot.exists) {
      final int currentLoad = snapshot.child('currentLoad').value as int;
      final int currentSolarGeneration =
          snapshot.child('currentSolarGeneration').value as int;

      // Retrieve relay statuses
      final Map<String, bool> relays = {};
      final relaysSnapshot = snapshot.child('relays');
      if (relaysSnapshot.exists) {
        // Create a list to hold relay entries
        final List<MapEntry<String, bool>> relayEntries = [];

        // Iterate over relay snapshots and collect entries
        for (var relay in relaysSnapshot.children) {
          relayEntries.add(MapEntry(relay.key!,
              relay.value as bool)); // Assuming the value is boolean
        }

        // Sort relay entries based on the relay names (keys)
        relayEntries.sort((a, b) => a.key.compareTo(b.key));

        // Add sorted entries to the relays map
        for (var entry in relayEntries) {
          relays[entry.key] = entry.value;
        }
      }

      final currentData = {
        'currentLoad': currentLoad,
        'currentSolarGeneration': currentSolarGeneration,
        'relays': relays, // Include relay statuses in the current data
      };

      // Call the callback function with the updated data
      onDataUpdated(currentData);
    } else {
      print('No data available');
      onDataUpdated(null);
    }
  }, onError: (error) {
    print('Error fetching data: $error');
    onDataUpdated(null);
  });
}
