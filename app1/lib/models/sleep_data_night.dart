import 'package:intl/intl.dart';

class SleepDataNight {
  final DateTime time;
  final int duration;
  final int minutesToFallAsleep;
  final int minutesAwake;
  final int minutesAfterWakeUp;
  final int deepMinutes;
  final int lightMinutes;
  final int remMinutes;

  SleepDataNight({
    required this.time,
    required this.duration,
    required this.minutesToFallAsleep,
    required this.minutesAwake,
    required this.minutesAfterWakeUp,
    required this.deepMinutes,
    required this.lightMinutes,
    required this.remMinutes,
  });

  // Helper to safely parse int from dynamic
  static int _parseInt(dynamic value) {
    if (value == null) return 0; // Handle null values safely
    if (value is int) return value;
    if (value is String) {
      // Clean the string before parsing, e.g., remove non-numeric chars if any
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }

  SleepDataNight.fromJson(String date, Map<String, dynamic> json)
      : time = _parseDateTimeForNight(date, json["startTime"]),
        duration = (_parseInt(json["duration"]) ~/ 60000),
        minutesToFallAsleep = _parseInt(json["minutesToFallAsleep"]),
        minutesAwake = _parseInt(json["minutesAwake"]),
        minutesAfterWakeUp = _parseInt(json["minutesAfterWakeUp"]),
        deepMinutes = _parseInt(json["levels"]?["summary"]?["deep"]?["minutes"]),
        lightMinutes = _parseInt(json["levels"]?["summary"]?["light"]?["minutes"]),
        remMinutes = _parseInt(json["levels"]?["summary"]?["rem"]?["minutes"]);

  static DateTime _parseDateTimeForNight(String date, dynamic startTime) {
    String cleanedTime = "00:00:00"; // Fallback di default
    if (startTime is String) {
      // Questo regex cerca il pattern "HH:MM:SS" (due cifre : due cifre : due cifre)
      // all'interno della stringa startTime, preferendo l'ultimo occorrenza
      // per catturare l'ora effettiva di inizio del sonno.
      final RegExp timeRegex = RegExp(r'(\d{2}:\d{2}:\d{2})$');
      final match = timeRegex.firstMatch(startTime);

      if (match != null) {
        cleanedTime = match.group(0)!; // Prende la stringa corrispondente all'intero match
      } else {
        print('Warning: Could not find HH:MM:SS pattern in startTime string "$startTime"'); // DEBUG
      }
    }

    final String fullDateTimeString = '$date $cleanedTime';
    print('Attempting to parse night date: $fullDateTimeString'); // DEBUG

    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(fullDateTimeString);
    } catch (e) {
      print('Error parsing SleepDataNight time string "$fullDateTimeString": $e');
      // Fallback: parse only the date part if time causes issues
      try {
        return DateFormat('yyyy-MM-dd').parse(date);
      } catch (dateError) {
        print('Error parsing only date part: $dateError');
        return DateTime.now(); // Final fallback
      }
    }
  }

  @override
  String toString() {
    return 'SleepDataNight(time: $time, duration: $duration, deep: $deepMinutes, light: $lightMinutes, rem: $remMinutes)';
  }
}