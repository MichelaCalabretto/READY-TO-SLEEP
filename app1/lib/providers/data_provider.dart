import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/utils/impact.dart';

class SleepDataProvider extends ChangeNotifier {
  List<SleepDataTrend> trendData = [];
  List<SleepDataNight> nightData = [];

  Future<void> fetchSleepTrendData(String startDate, String endDate) async { //in input you give the startDate and endDate
    final data = await Impact.fetchSleepTrendData(startDate, endDate); // Usato Impact.fetchSleepTrendData con 2 date
    
    if (data != null) {
      trendData.clear();
      for (var item in data['data']['data']) {
        trendData.add(SleepDataTrend.fromJson(data['data']['date'], item));
      }
      notifyListeners();
    }
  }

  Future<void> fetchSleepNightData(String day) async {
    final data = await Impact.fetchSleepNightData(day); 
    if (data != null) {
      nightData.clear();
      for (var item in data['data']['data']) {
        nightData.add(SleepDataNight.fromJson(data['data']['date'], item));
      }
      notifyListeners();
    }
  }

  void clearData() {
    trendData.clear();
    nightData.clear();
    notifyListeners();
  }
}
