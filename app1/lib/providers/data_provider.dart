import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/utils/impact.dart';

class SleepDataProvider extends ChangeNotifier {

  List<SleepDataTrend> sleepTrendData = []; // List of sleep trends (for multiple days)
  SleepDataNight? sleepNightData; // Single night data

  /// Fetch sleep trend data for a date range (e.g., a week or month)
  Future<void> fetchSleepTrendData(String startDate, String endDate) async {
    final data = await Impact.fetchSleepTrendData(startDate, endDate); // raw API response

    if (data != null && data['data'] is List) { // the response is not null and data is a List (that contains the trend entries for each day)
      sleepTrendData.clear(); // Clear old data

      for (var dailyEntry in data['data']) { // loop through each element of the response
        final date = dailyEntry['date']; // extraction of the day
        final entries = dailyEntry['data']; // extraction of the associated data for that day

        if (date != null && entries != null) { // check that both date and entries are not null
          final parsed = SleepDataTrend.fromApiData(date, entries); // safely handles both Map and List
          if (parsed != null) {
            sleepTrendData.add(parsed); // adds it to the list
          }
        }
      }
      notifyListeners(); // notifyListeners() is called only after all the data is processed
    } else {
      // If no valid data returned, clear existing trend data and notify listeners to update UI
      sleepTrendData.clear();
      notifyListeners();
    }
  }

  /// Fetch detailed sleep data for a specific night
  Future<void> fetchSleepNightData(String day) async {
    final data = await Impact.fetchSleepNightData(day); // raw API response

    if (data != null && // if the response is not null
        data['data'] is Map && // and data is a Map
        data['data']['data'] != null) { // and the expected actual sleep data list for the night is not null
      final sleepJson = data['data']['data']; // handles nested map with list
      final parsed = SleepDataNight.fromApiData(day, sleepJson); // safely handles both formats

      if (parsed != null) {
        sleepNightData = parsed; // creates the sleepDataNight object
      } else {
        // Parsing failed, clear the existing night data
        sleepNightData = null;
      }
    } else {
      // If data is null or structure unexpected, clear existing night data
      sleepNightData = null;
    }
    notifyListeners(); // Always notify listeners on data fetch attempt
  }

  /// Clears both trend and night data
  void clearSleepData() {
    sleepTrendData.clear();
    sleepNightData = null;
    notifyListeners();
  }
}
