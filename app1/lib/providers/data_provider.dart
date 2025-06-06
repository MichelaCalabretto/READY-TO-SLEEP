import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/utils/impact.dart';
import 'package:intl/intl.dart';

class SleepDataProvider extends ChangeNotifier {

  List<SleepDataTrend> sleepTrendData = []; // List of sleep trends (for multiple days)
  SleepDataNight? sleepNightData; // Single night data, for chart_switcher
  
  SleepDataNight? _yesterdaysSleepDetail; // New properties for yesterday's specific sleep data
  SleepDataNight? get yesterdaysSleepDetail => _yesterdaysSleepDetail;

  bool _isLoadingYesterdaysSleep = false;
  bool get isLoadingYesterdaysSleep => _isLoadingYesterdaysSleep;

  // Flag to ensure we attempt to fetch yesterday's data only once per relevant period
  // or if the "yesterday" date changes (e.g. app open over midnight)
  String? _lastFetchedYesterdayDate;

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

  /// Ensures that sleep data for the actual "yesterday" is fetched and available.
  Future<void> ensureYesterdaysSleepDataFetched() async {
    final String yesterdayDateString =
        DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

    // If already loading for the current "yesterday", or if data for current "yesterday" is already loaded, do nothing.
    if (_isLoadingYesterdaysSleep && _lastFetchedYesterdayDate == yesterdayDateString) return; //checks if it's already loading data and if the last fetch was already for yesterday ---> if it's already fetching data, don't start another fetch
    if (_yesterdaysSleepDetail != null && _lastFetchedYesterdayDate == yesterdayDateString && _yesterdaysSleepDetail!.time == yesterdayDateString) { //if we already have data, and it is for the correct date, and the stored data actually matched the yesterday's date
        return;
    }

    _isLoadingYesterdaysSleep = true;
    _lastFetchedYesterdayDate = yesterdayDateString; // Mark the date we are fetching for
    notifyListeners();

    final data = await Impact.fetchSleepNightData(yesterdayDateString);

    if (data != null &&
        data['data'] is Map &&
        data['data']['data'] != null) {
      final sleepJson = data['data']['data'];
      final parsed = SleepDataNight.fromApiData(yesterdayDateString, sleepJson);
      _yesterdaysSleepDetail = parsed; // Can be null if parsing failed
    } else {
      _yesterdaysSleepDetail = null; // Fetching failed or no data
    }

    _isLoadingYesterdaysSleep = false;
    notifyListeners();
  }

  /// Clears both trend and night data
  void clearSleepData() {
    sleepTrendData.clear();
    sleepNightData = null;
    notifyListeners();
  }

}
