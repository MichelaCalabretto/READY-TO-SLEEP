import 'package:intl/intl.dart';

class SleepDataTrend {
  final DateTime time;
  final int duration;

  SleepDataTrend({
    required this.time,
    required this.duration,
  });

  factory SleepDataTrend.fromJson(Map<String, dynamic> json) {
    try {
      // 1. Parsing della data
      DateTime parsedTime;
      final dynamic timeData = json['date'] ?? json['time'] ?? json['dateOfSleep']; // Prioritize 'date' for trend data

      if (timeData is String) {
        try {
          if (timeData.contains(' ')) {
            parsedTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timeData);
          } else {
            parsedTime = DateFormat('yyyy-MM-dd').parse(timeData);
          }
        } catch (e) {
          print('Error parsing date string "$timeData" for SleepDataTrend: $e');
          parsedTime = DateTime.now(); // Fallback
        }
      } else {
        parsedTime = DateTime.now(); // Fallback
      }

      // 2. NUOVA GESTIONE DURATA (ROBUSTA)
      int parsedDuration = 0;
      // Access the first item in the 'data' list, which contains the sleep details for the day
      if (json['data'] is List && json['data'].isNotEmpty) {
        final Map<String, dynamic> dailySleepSummary = json['data'][0];
        
        final dynamic durationData = dailySleepSummary['totalMinutesAsleep'] ?? 
                                     dailySleepSummary['duration'] ?? // This is in milliseconds
                                     dailySleepSummary['minutesAsleep'] ?? // This is in minutes
                                     dailySleepSummary['timeInBed'];

        if (durationData == null) {
          parsedDuration = 0;
        } else if (durationData is int) {
          // Check if it's likely milliseconds (very large number) and convert to minutes
          if (durationData > 1000000) { // Arbitrary large number to distinguish ms from mins
            parsedDuration = (durationData ~/ 60000); // ms to mins
          } else {
            parsedDuration = durationData; // Assume it's already in minutes
          }
        } else if (durationData is String) {
          final cleanStr = durationData.replaceAll(RegExp(r'[^0-9]'), '');
          int? tempParsed = int.tryParse(cleanStr);
          if (tempParsed != null) {
            // Check if it's likely milliseconds
            if (tempParsed > 1000000) {
              parsedDuration = (tempParsed ~/ 60000);
            } else {
              parsedDuration = tempParsed;
            }
          } else {
             parsedDuration = 0;
          }
          print('Cleaned duration: $cleanStr -> $parsedDuration mins');
        } else {
          print('Unexpected duration type in dailySleepSummary: ${durationData.runtimeType}');
          parsedDuration = 0;
        }
      } else {
        print('Warning: No daily sleep summary data found for trend on $parsedTime');
      }

      return SleepDataTrend(
        time: parsedTime,
        duration: parsedDuration,
      );
    } catch (e, stack) {
      print('Error creating SleepDataTrend: $e\n$stack');
      return SleepDataTrend(
        time: DateTime.now(),
        duration: 0,
      );
    }
  }

  @override
  String toString() {
    return 'SleepDataTrend(time: $time, duration: $duration mins)';
  }
}