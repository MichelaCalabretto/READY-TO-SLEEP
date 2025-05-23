import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartSwitcher extends StatefulWidget {
  const ChartSwitcher({Key? key}) : super(key: key);

  @override
  _ChartSwitcherState createState() => _ChartSwitcherState();
}

class _ChartSwitcherState extends State<ChartSwitcher> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final Color themePurple = const Color.fromARGB(255, 38, 9, 68); // theme color
  final Color chartBgColor = Colors.white70; // light transparent background

  // Return a dynamic title based on the current index
  String get chartTitle {
    switch (_currentIndex) {
      case 0:
        return "Tonight's recap";
      case 1:
        return 'Trend of the last 7 days';
      default:
        return '';
    }
  }

  // Build a line chart using fl_chart
  Widget _buildLineChart() {
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
              spots: const [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2),
                FlSpot(3, 5),
              ],
              isCurved: true,
              color: themePurple,
              barWidth: 4,
            ),
          ],
        ),
      ),
    );
  }

  // Build a bar chart using fl_chart
  Widget _buildBarChart() {
    return Container(
      decoration: BoxDecoration(
        color: chartBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: BarChart(
        BarChartData(
          backgroundColor: Colors.transparent,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 3, color: themePurple)],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: 5, color: themePurple)],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 2, color: themePurple)],
            ),
          ],
        ),
      ),
    );
  }

  // Build dot indicators for page index
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display title above chart
        Text(
          chartTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black54,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Chart area with swipe navigation
        SizedBox(
          height: 300,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildLineChart(),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildBarChart(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Dot indicators under the chart
        _buildDotIndicators(),
      ],
    );
  }
}
