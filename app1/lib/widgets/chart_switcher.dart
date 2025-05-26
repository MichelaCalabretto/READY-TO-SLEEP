import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:app1/models/sleep_data_trend.dart';

class ChartSwitcher extends StatefulWidget {
  final List<SleepDataNight> sleepDataNights;
  final List<SleepDataTrend> sleepDataTrends;

  const ChartSwitcher({
    Key? key,
    required this.sleepDataNights,
    required this.sleepDataTrends,
  }) : super(key: key);

  @override
  _ChartSwitcherState createState() => _ChartSwitcherState();
}

class _ChartSwitcherState extends State<ChartSwitcher> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Define colors for theme consistency
  final Color themePurple = const Color.fromARGB(255, 38, 9, 68);
  final Color chartBgColor = Colors.white70;

  // The selected date; initialized to yesterday on widget load
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    // Set default selectedDate to yesterday (latest viable date)
    selectedDate = DateTime.now().subtract(const Duration(days: 1));
  }

  // Filter sleep data for the exact selected date (night recap)
  List<SleepDataNight> get filteredSleepDataNights {
    return widget.sleepDataNights.where((data) {
      return data.time.year == selectedDate.year &&
          data.time.month == selectedDate.month &&
          data.time.day == selectedDate.day;
    }).toList();
  }

  // Filter sleep trends for 7-day period ending on selectedDate
  List<SleepDataTrend> get filteredSleepDataTrends {
    DateTime startDate = selectedDate.subtract(const Duration(days: 6));
    return widget.sleepDataTrends.where((data) {
      // Include data between startDate and selectedDate inclusive
      return data.time.isAfter(startDate.subtract(const Duration(days: 1))) &&
          data.time.isBefore(selectedDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Chart title changes depending on which chart page is visible
  String get chartTitle {
    switch (_currentIndex) {
      case 0:
        return "Tonight's Recap";
      case 1:
        return "Trend of the Last 7 Days";
      default:
        return '';
    }
  }

  // Build Bar Chart for single night sleep data
  Widget _buildBarChart() {
    // Show a message if no data available for the selected date
    if (filteredSleepDataNights.isEmpty) {
      return const Center(
        child: Text(
          'No data available for the selected night.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final data = filteredSleepDataNights.first;

    // Create bar groups for Deep, Light, and REM sleep durations (converted to hours)
    final barGroups = <BarChartGroupData>[
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(toY: data.deepMinutes / 60, color: themePurple, width: 20)
      ], showingTooltipIndicators: [0]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(toY: data.lightMinutes / 60, color: themePurple, width: 20)
      ], showingTooltipIndicators: [0]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(toY: data.remMinutes / 60, color: themePurple, width: 20)
      ], showingTooltipIndicators: [0]),
    ];

    // Return styled BarChart widget wrapped in a decorated container
    return Container(
      decoration: BoxDecoration(
        color: chartBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: BarChart(
        BarChartData(
          backgroundColor: Colors.transparent,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Deep');
                    case 1:
                      return const Text('Light');
                    case 2:
                      return const Text('REM');
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          // Enable tooltip on bar touch
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final stage = ['Deep Sleep', 'Light Sleep', 'REM Sleep'][group.x.toInt()];
                return BarTooltipItem(
                  '$stage: ${rod.toY.toStringAsFixed(2)} hrs',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Build Line Chart for 7-day sleep trend data
  Widget _buildLineChart() {
    if (filteredSleepDataTrends.isEmpty) {
      return const Center(
        child: Text(
          'No data available for the selected period.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Create FlSpots with x = days offset from start of 7-day window, y = duration in hours
    final spots = filteredSleepDataTrends.map((data) {
      final daysAgo = selectedDate.difference(data.time).inDays;

      // Safely parse duration regardless of it being int, double, or String
      double duration;
      if (data.duration is String) {
        duration = double.tryParse(data.duration as String) ?? 0.0;
      } else if (data.duration is int) {
        duration = (data.duration as int).toDouble();
      } else if (data.duration is double) {
        duration = data.duration as double;
      } else {
        duration = 0.0;
      }

      return FlSpot(
        (6 - daysAgo).toDouble(),
        duration / 60,
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: chartBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: themePurple,
              barWidth: 4,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, _) {
                  // Show day abbreviations (Mon, Tue, etc) for bottom axis
                  final date = selectedDate.subtract(Duration(days: 6 - value.toInt()));
                  return Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          // Enable tooltip on line touch
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Duration: ${spot.y.toStringAsFixed(2)} hrs',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  // Dot indicators to show which chart page is active
  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 12 : 8,
          height: _currentIndex == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index ? Colors.white : Colors.white54,
          ),
        );
      }),
    );
  }

  // Show date picker dialog allowing user to pick a date up to yesterday only
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // earliest selectable date
      lastDate: DateTime.now().subtract(const Duration(days: 1)), // yesterday is max
    );
    if (picked != null && picked != selectedDate) {
      // Update selectedDate and refresh UI to update charts
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date selector button with calendar icon and formatted date text
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today, size: 18),
            // Show selected date formatted 
            label: Text(DateFormat.yMMMd().format(selectedDate)),
            style: ElevatedButton.styleFrom(
              backgroundColor: themePurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        // Chart title depends on current chart page
        Text(
          chartTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 1))],
          ),
        ),

        const SizedBox(height: 16),

        // Chart area with PageView to switch between bar chart and line chart
        SizedBox(
          height: 300,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: [
              Padding(padding: const EdgeInsets.all(16), child: _buildBarChart()),
              Padding(padding: const EdgeInsets.all(16), child: _buildLineChart()),
            ],
          ),
        ),

        const SizedBox(height: 12),
        // Show dots for page indicator below the chart
        _buildDotIndicators(),
      ],
    );
  }
}
