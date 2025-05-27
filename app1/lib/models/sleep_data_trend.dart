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
      final dynamic timeData = json['time'] ?? json['date'] ?? json['dateOfSleep'];

      if (timeData is String) {
        try {
          if (timeData.contains(' ')) {
            parsedTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(timeData);
          } else {
            parsedTime = DateFormat('yyyy-MM-dd').parse(timeData);
          }
        } catch (e) {
          print('Error parsing date string "$timeData": $e');
          parsedTime = DateTime.now();
        }
      } else {
        parsedTime = DateTime.now();
      }

      // 2. NUOVA GESTIONE DURATA (ROBUSTA)
      int parsedDuration;
      final dynamic durationData = json['totalMinutesAsleep'] ?? 
                                 json['duration'] ?? 
                                 json['minutesAsleep'] ?? 
                                 json['timeInBed'];

      if (durationData == null) {
        parsedDuration = 0;
      } else if (durationData is int) {
        parsedDuration = durationData ~/ 60000; // ms to mins
      } else if (durationData is String) {
        final cleanStr = durationData.replaceAll(RegExp(r'[^0-9]'), '');
        parsedDuration = (int.tryParse(cleanStr) ?? 0) ~/ 60000;
        print('Cleaned duration: $cleanStr → $parsedDuration mins');
      } else {
        print('Unexpected duration type: ${durationData.runtimeType}');
        parsedDuration = 0;
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