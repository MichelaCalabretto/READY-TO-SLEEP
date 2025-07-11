import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/utils/impact.dart';
import 'package:intl/intl.dart';

class SleepDataProvider extends ChangeNotifier {

  List<SleepDataTrend> sleepTrendData = []; // list of sleep trends (for multiple days) initialized as empty
  SleepDataNight? sleepNightData; // single night data
  
  // Data shown in the UserGreetingWithAvatar
  SleepDataNight? _yesterdaysSleepDetail; // _yesterdaySleepDetail is a private variable that holds the SleepDataNight object of the previous night (it's nullable because there could be no data, and for when the data hasn't been fetched yet)
  SleepDataNight? get yesterdaysSleepDetail => _yesterdaysSleepDetail; // getter that allows the UserGreetingWithAvatar to read the yesterdaySleepDetail but not modify it
                                                                       // => = return
  bool _isLoadingYesterdaysSleep = false; // flag to track whether the app is currently in the middle of fetching yesterday's sleep data
  bool get isLoadingYesterdaysSleep => _isLoadingYesterdaysSleep; // getter for the loadingState (read only): if True the UserGreetingWithAvatar will show a CircularProgressIndicator, if False the greeting

  // Flag to ensure we attempt to fetch yesterday's data only once per relevant period or if the "yesterday" date changes (i.e. app open over midnight)
  String? _lastFetchedYesterdayDate;

  // Fetch sleep trend data for a date range 
  Future<void> fetchSleepTrendData(String startDate, String endDate) async {
    final data = await Impact.fetchSleepTrendData(startDate, endDate); // raw API response
                                                                       // method defined in impact.dart that just makes the request to the server and returns the response decoded (from JSON) in Dart language

    if (data != null && data['data'] is List) { // the response is not null and data is a List (which is the expected format) (that contains the trend entries for each day)
      sleepTrendData.clear(); // clear old data

      for (var dailyEntry in data['data']) { // loop through each element of the response
        final date = dailyEntry['date']; // extraction of the day
        final entries = dailyEntry['data']; // extraction of the associated data for that day

        if (date != null && entries != null) { // check that both date and entries are not null
          final parsed = SleepDataTrend.fromApiData(date, entries); // safely handles both Map and List formt
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

  // Fetch detailed sleep data for a specific night
  Future<void> fetchSleepNightData(String day) async {
    final data = await Impact.fetchSleepNightData(day); // raw API response
                                                        // method defined in impact.dart that just makes the request to the server and returns the response decoded (from JSON) in Dart language

    if (data != null && // if the response is not null
        data['data'] is Map && // and data is a Map
        data['data']['data'] != null) { // and the expected actual sleep data list for the night is not null
      final sleepJson = data['data']['data']; // can be a List with inside a Map or directly a Map ---> the format is then handled by the fromApiData
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
    notifyListeners(); // always notify listeners on data fetch attempt
  }

  // Ensures that sleep data for the actual "yesterday" is fetched and available
  // Data is not fetched for general use in the app, but for updating the variables used by the UserGreetingWithAvatar
  Future<void> ensureYesterdaysSleepDataFetched() async {
    final String yesterdayDateString =
        DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1))); // get yesterday's date

    // If already loading for the current "yesterday", or if data for current "yesterday" is already loaded, do nothing
    if (_isLoadingYesterdaysSleep && _lastFetchedYesterdayDate == yesterdayDateString) return; // checks if it's already loading data and if the last fetch was already for yesterday ---> if it's already fetching data, don't start another fetch
    if (_yesterdaysSleepDetail != null && _lastFetchedYesterdayDate == yesterdayDateString && _yesterdaysSleepDetail!.time == yesterdayDateString) { // if we already have data, and it is for the correct date, and the stored data actually matched the yesterday's date
        return;
    }

    // Here, the code is run only if the data from yesterday was not already fetched
    _isLoadingYesterdaysSleep = true;
    _lastFetchedYesterdayDate = yesterdayDateString; // update the date we are fetching for
    notifyListeners(); // must notify the UserGreetingAvatar that new data is being fetched

    final data = await Impact.fetchSleepNightData(yesterdayDateString); // use the Impact method because we need to update the variables for the UserGreetingWithAvatar

    if (data != null &&
        data['data'] is Map &&
        data['data']['data'] != null) {
      final sleepJson = data['data']['data'];
      final parsed = SleepDataNight.fromApiData(yesterdayDateString, sleepJson);
      _yesterdaysSleepDetail = parsed; // can be null if parsing failed
                                       // this is the data shown in the greeting, not in the chart_switcher
    } else {
      _yesterdaysSleepDetail = null; // fetching failed or no data
    }

    _isLoadingYesterdaysSleep = false;
    notifyListeners();
  }

  // Clears both trend and night data
  void clearSleepData() {
    sleepTrendData.clear();
    sleepNightData = null;
    notifyListeners();
  }

}
