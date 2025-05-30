import 'package:intl/intl.dart';

class SleepDataTrend {
  final String time; // Date in format yyyy-MM-dd
  final int duration; // Sleep duration in minutes

  /// Handles inconsistent API structures for the trend data
  static SleepDataTrend? fromApiData(String date, dynamic data) {
    if (data == null) return null;

    // If data is a non-empty List, use the first element if it's a Map
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return SleepDataTrend.fromJson(date, data.first);
    }

    // If data is a single Map, parse it directly
    if (data is Map<String, dynamic>) {
      return SleepDataTrend.fromJson(date, data);
    }

    // In all other cases (e.g., wrong types), return null
    return null;
  }

  /// Constructor using initializer list to extract values from JSON
  /// [date] is passed from the outer structure (e.g., "2025-05-21")
  /// [json] is the sleep data map containing the duration in ms
  SleepDataTrend.fromJson(String date, Map<String, dynamic> json)
      : time = date, // Directly assign the provided date as the time
        duration = (json['duration'] ?? 0) ~/ 60000; // Convert duration from ms to min

  @override
  String toString() {
    return 'SleepDataTrend(time: $time, duration: $duration minutes)';
  }
}
