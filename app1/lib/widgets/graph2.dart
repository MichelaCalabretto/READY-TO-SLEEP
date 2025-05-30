import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Graph2 extends StatefulWidget {
  /// Input list of 7 days of trend data
  final List<SleepDataTrend> trendData;

  /// The selected end date (usually yesterday), needed to compute the 7-day range
  final DateTime endDate;

  const Graph2({Key? key, required this.trendData, required this.endDate}) : super(key: key);

  @override
  State<Graph2> createState() => _Graph2State();
}

class _Graph2State extends State<Graph2> {
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227); // memorized color
  final Color backgroundWhiteShade = Colors.white70.withOpacity(0.2); // translucent white background

  // Helper: format date as "MMM d" (e.g., May 27)
  String formatDate(DateTime date) => DateFormat('MMM d').format(date);

  // Helper: convert minutes to hours (decimal)
  double minutesToHours(int minutes) => minutes / 60;

  // Helper: format duration in "Xh Ym"
  String formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    // Create 7-day range ending at selected endDate
    final days = List<DateTime>.generate(7, (i) => widget.endDate.subtract(Duration(days: 6 - i)));

    // Map input data to a lookup table by date string
    final dataByDate = {
      for (var t in widget.trendData)
        // Defensive: parse the date safely and format it as string key
        DateFormat('yyyy-MM-dd').format(DateTime.parse(t.time)): t,
    };

    // Prepare chart spots: exactly 7 x-values from 0 to 6
    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final dayKey = DateFormat('yyyy-MM-dd').format(days[i]);
      final trend = dataByDate[dayKey];

      // Add spot with y-value only if duration is not null and greater than zero
      // Added check for > 0 to avoid zero-value spots cluttering the chart
      if (trend?.duration != null && trend!.duration! > 0) {
        spots.add(FlSpot(i.toDouble(), minutesToHours(trend.duration!)));
      } else {
        // To keep consistent x-axis spacing, add a spot with y=0 for missing data
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }

    // If all spots have y=0 (i.e., no meaningful data)
    final allZero = spots.every((spot) => spot.y == 0);
    if (allZero) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          'No trend data available for this week.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundWhiteShade,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // to allow center alignment
        children: [
          const Center( // centered title
            child: Text(
              'Sleep Trend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0, //min Y-axis value
                maxY: 12, //max Y-axis value
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 2,
                  verticalInterval: 1, //this way I have a line per day
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.white24, strokeWidth: 1),
                  getDrawingVerticalLine: (value) =>
                      FlLine(color: Colors.white24, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),

                // X and Y axis titles
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) return Container();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            formatDate(days[index]),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      reservedSize: 28,
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                // The line itself
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: darkPurple,
                    barWidth: 3,
                    isStrokeCapRound: true, //to round the ends of lines
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        // Only show dot if this spot's y > 0 (meaningful data)
                        if (spot.y <= 0) {
                          return FlDotCirclePainter(
                            radius: 0, // zero radius = invisible dot
                            color: Colors.transparent,
                            strokeColor: Colors.transparent,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 5,
                          color: darkPurple, //fill color of the dot
                          strokeColor: Colors.white, //border color of the plot
                        );
                      },
                    ),

                    // Added belowBarData to create a shadow (area) under the line
                    belowBarData: BarAreaData(
                      show: true,
                      color: darkPurple.withOpacity(0.25), // darkPurple color with transparency for shadow
                      /*gradient: LinearGradient(
                        colors: [
                          darkPurple.withOpacity(0.3),
                          darkPurple.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),*/
                    ),
                  ),
                ],

                lineTouchData: LineTouchData(
                  getTouchedSpotIndicator:
                      (barData, List<int> spotIndexes) => spotIndexes.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(color: Colors.transparent),
                              FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: lilla,
                                    strokeColor: Colors.white,
                                    strokeWidth: 2,
                                  );
                                },
                              ),
                            );
                          }).toList(),
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: lilla,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final date = formatDate(days[index]);
                        final duration = dataByDate[DateFormat('yyyy-MM-dd').format(days[index])]
                            ?.duration;
                        final formattedDuration =
                            duration != null ? formatDuration(duration) : 'No data';
                        return LineTooltipItem(
                          '$date\n$formattedDuration',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
