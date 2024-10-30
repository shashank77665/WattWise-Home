import 'package:cloud_firestore/cloud_firestore.dart';

class SensorData {
  final int currentSolarGeneration;
  final int currentLoad;
  final DateTime timestamp;

  SensorData({
    required this.currentSolarGeneration,
    required this.currentLoad,
    required this.timestamp,
  });

  // Factory constructor to create a SensorData instance from a map
  factory SensorData.fromMap(Map<String, dynamic> data) {
    // Check if timestamp is a Firebase Timestamp, then convert it to DateTime
    DateTime timestamp = (data['timestamp'] is Timestamp)
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.fromMillisecondsSinceEpoch(
            data['timestamp']['seconds'] * 1000 +
                data['timestamp']['nanoseconds'] ~/ 1000000,
          );

    return SensorData(
      currentSolarGeneration: data['currentSolarGeneration'],
      currentLoad: data['currentLoad'],
      timestamp: timestamp,
    );
  }

  // Method to convert SensorData instance to a map
  Map<String, dynamic> toMap() {
    return {
      'currentSolarGeneration': currentSolarGeneration,
      'currentLoad': currentLoad,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class DailyEnergyStats {
  double todayTotalConsumption;
  double todayTotalGeneration;
  double maxLoad;
  double avgLoad;
  double minLoad;
  double maxCurrent;
  double avgCurrent;
  double minCurrent;

  DailyEnergyStats({
    required this.todayTotalConsumption,
    required this.todayTotalGeneration,
    required this.maxLoad,
    required this.avgLoad,
    required this.minLoad,
    required this.maxCurrent,
    required this.avgCurrent,
    required this.minCurrent,
  });

  // Optional: toString() method for easy debugging
  @override
  String toString() {
    return 'DailyEnergyStats(todayTotalConsumption: $todayTotalConsumption, todayTotalGeneration: $todayTotalGeneration, maxLoad: $maxLoad, avgLoad: $avgLoad, minLoad: $minLoad, maxCurrent: $maxCurrent, avgCurrent: $avgCurrent, minCurrent: $minCurrent)';
  }
}

class EnergyStats {
  double totalConsumption;
  double totalGenerated;
  DateTime maxConsumedOn;
  double maxConsumedReading;
  double avgConsumptionReading;
  DateTime leastConsumedOn;
  double leastConsumedReading;
  DateTime maxGeneratedOn;
  double maxGenerationReading;
  double avgGenerationReading;
  DateTime leastGeneratedOn;
  double leastGenerationReading;

  EnergyStats({
    required this.totalConsumption,
    required this.totalGenerated,
    required this.maxConsumedOn,
    required this.maxConsumedReading,
    required this.avgConsumptionReading,
    required this.leastConsumedOn,
    required this.leastConsumedReading,
    required this.maxGeneratedOn,
    required this.maxGenerationReading,
    required this.avgGenerationReading,
    required this.leastGeneratedOn,
    required this.leastGenerationReading,
  });

  // You can also add a method to convert the object to a Map if needed for serialization.
  Map<String, dynamic> toMap() {
    return {
      'totalConsumption': totalConsumption,
      'totalGenerated': totalGenerated,
      'maxConsumedOn': maxConsumedOn.toIso8601String(),
      'maxConsumedReading': maxConsumedReading,
      'avgConsumptionReading': avgConsumptionReading,
      'leastConsumedOn': leastConsumedOn.toIso8601String(),
      'leastConsumedReading': leastConsumedReading,
      'maxGeneratedOn': maxGeneratedOn.toIso8601String(),
      'maxGenerationReading': maxGenerationReading,
      'avgGenerationReading': avgGenerationReading,
      'leastGeneratedOn': leastGeneratedOn.toIso8601String(),
      'leastGenerationReading': leastGenerationReading,
    };
  }

  // You can also add a method to create an instance from a Map if needed.
  factory EnergyStats.fromMap(Map<String, dynamic> map) {
    return EnergyStats(
      totalConsumption: map['totalConsumption'],
      totalGenerated: map['totalGenerated'],
      maxConsumedOn: DateTime.parse(map['maxConsumedOn']),
      maxConsumedReading: map['maxConsumedReading'],
      avgConsumptionReading: map['avgConsumptionReading'],
      leastConsumedOn: DateTime.parse(map['leastConsumedOn']),
      leastConsumedReading: map['leastConsumedReading'],
      maxGeneratedOn: DateTime.parse(map['maxGeneratedOn']),
      maxGenerationReading: map['maxGenerationReading'],
      avgGenerationReading: map['avgGenerationReading'],
      leastGeneratedOn: DateTime.parse(map['leastGeneratedOn']),
      leastGenerationReading: map['leastGenerationReading'],
    );
  }
}
