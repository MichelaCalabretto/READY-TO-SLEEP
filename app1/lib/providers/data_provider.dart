import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/utils/impact.dart';

class SleepDataProvider extends ChangeNotifier {
  List<SleepDataTrend> trendData = [];
  List<SleepDataNight> nightData = [];

  Future<void> fetchSleepTrendData(String startDate, String endDate) async {
    final data = await Impact.fetchSleepTrendData(startDate, endDate);

    print('fetchSleepTrendData response: $data'); // DEBUG

    if (data != null) {
      trendData.clear();

      final list = data['data']['data'];
      if (list is List) {
        for (var item in list) {
          final date = item['time'] ?? item['startTime'] ?? '';
          print('Parsing trend item with date: $date'); // DEBUG

          // Updated to use new constructor (no separate date param)
          trendData.add(SleepDataTrend.fromJson(item));
        }
      } else {
        print('Expected a List in trend data but got: ${list.runtimeType}');
      }

      notifyListeners();
    } else {
      print('fetchSleepTrendData returned null');
    }
  }

  Future<void> fetchSleepNightData(String day) async {
    final data = await Impact.fetchSleepNightData(day);

    print('fetchSleepNightData response: $data'); // DEBUG

    if (data != null) {
      nightData.clear();

      final dynamic item = data['data']?['data'];
      final String? date = data['data']?['date'];

      print('Parsing night data for date: $date'); // DEBUG
      print('Night data raw item: $item (type: ${item.runtimeType})'); // DEBUG

      if (item != null && item is Map<String, dynamic> && date != null) {
        nightData.add(SleepDataNight.fromJson(date, item));
      } else {
        print('Night data item is null or not a Map');
      }

      notifyListeners();
    } else {
      print('fetchSleepNightData returned null');
    }
  }

  void clearData() {
    trendData.clear();
    nightData.clear();
    notifyListeners();
  }
}
