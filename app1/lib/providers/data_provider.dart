import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/utils/impact.dart';

class SleepDataProvider extends ChangeNotifier {
  List<SleepDataTrend> trendData = [];
  List<SleepDataNight> nightData = [];

  Future<void> fetchSleepTrendData(String startDate, String endDate) async {
    try {
      final data = await Impact.fetchSleepTrendData(startDate, endDate);
      print('RAW TREND RESPONSE: ${data?.toString()}');

      if (data != null && data['data'] != null) {
        trendData.clear();
        
        final items = data['data']['data'] ?? [];
        if (items is List) {
          for (var item in items) {
            try {
              print('PROCESSING TREND ITEM: $item');
              trendData.add(SleepDataTrend.fromJson(item));
            } catch (e, stack) {
              print('Error processing trend item: $e\n$stack');
            }
          }
        }
        
        notifyListeners();
        print('Successfully loaded ${trendData.length} trend items');
      }
    } catch (e, stack) {
      print('Error in fetchSleepTrendData: $e\n$stack');
    }
  }

  Future<void> fetchSleepNightData(String day) async {
    try {
      final data = await Impact.fetchSleepNightData(day);
      print('RAW NIGHT RESPONSE: ${data?.toString()}');

      if (data != null && data['data'] != null) {
        nightData.clear();
        
        final responseData = data['data']['data'];
        final date = data['data']['date'];
        
        if (responseData is List && responseData.isNotEmpty && date != null) {
          try {
            nightData.add(SleepDataNight.fromJson(date, responseData.first));
            print('Successfully loaded night data');
          } catch (e, stack) {
            print('Error processing night data: $e\n$stack');
          }
        }
        
        notifyListeners();
      }
    } catch (e, stack) {
      print('Error in fetchSleepNightData: $e\n$stack');
    }
  }

  void clearData() {
    trendData.clear();
    nightData.clear();
    notifyListeners();
  }
}