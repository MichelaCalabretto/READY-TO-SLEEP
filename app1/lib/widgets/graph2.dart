import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_trend.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Graph2 extends StatefulWidget {
  // Input list of 7 days of trend data
  final List<SleepDataTrend> trendData;

  // The selected end date (needed to compute the 7-day range)
  final DateTime endDate;

  const Graph2({Key? key, required this.trendData, required this.endDate}) : super(key: key);

  @override
  State<Graph2> createState() => _Graph2State();
}

class _Graph2State extends State<Graph2> {
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227); 
  final Color backgroundWhiteShade = Colors.white70.withOpacity(0.2); 

  // Helper to format date as "MMM d" (i.e., May 27)
  String formatDate(DateTime date) => DateFormat('MMM d').format(date);

  // Helper to convert minutes to hours (decimal)
  double minutesToHours(int minutes) => minutes / 60;

  // Helper to format duration in "X h Y min"
  String formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h h $m m';
  }

  @override
  Widget build(BuildContext context) {
    // Create 7-day range ending at selected endDate
    final days = List<DateTime>.generate(7, (i) => widget.endDate.subtract(Duration(days: 6 - i))); // List<DateTime>.generate(7, ...) ---> creates a list with 7 elements
                                                                                                    // for each element at index i (from 0 to 6), it runs the function (i) => ...

    // Map input data to a lookup table by date string
    final dataByDate = { // from List<SleepDataTrend> trendData ---> to Map<String, SleepDataTrend> dataByDate
      for (var t in widget.trendData)
        // Parse the date safely and format it as string key
        DateFormat('yyyy-MM-dd').format(DateTime.parse(t.time)): t, // DateTime.parse(t.time) ---> converts the String date into a dateTime format
                                                                    // then stores the SleepDataTrend object t as the value corresponding to the date ---> date : SleepDataTrend object
    };

    // Prepare chart spots: exactly 7 X-values from 0 to 6
    final spots = <FlSpot>[]; // FlSpot is used by fl_chart to represent a point on the line chart, with an x and y value (there will be one for each day)
    for (int i = 0; i < days.length; i++) { 
      final dayKey = DateFormat('yyyy-MM-dd').format(days[i]); // extract the date
      final trend = dataByDate[dayKey]; // extract the corresponding SleepDataTrend object

      // Add spot with Y-value only if duration is not null and greater than zero
      // Added check for > 0 to avoid zero-value spots cluttering the chart
      if (trend?.duration != null && trend!.duration > 0) {
        spots.add(FlSpot(i.toDouble(), minutesToHours(trend.duration))); // the index is converted to double because FlSpot requires it
      } else {
        // To keep consistent X-axis spacing, add a spot with y=0 for missing data
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }

    // If all spots have y=0 (i.e., no meaningful data)
    final allZero = spots.every((spot) => spot.y == 0); // .every() is a method that checks if every element in the list satisfies a given condition (if the y value of each spot is equal to zero)
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
        crossAxisAlignment: CrossAxisAlignment.stretch, // stretches to take all the horizontal space aviable
        children: [
          const Center( 
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

          Expanded( // this way the widget will take all the aviable space
            // Widget that renders the line chart
            child: LineChart(
              LineChartData( // configuration object for the chart that tells the LineChart what data to plot and how to style it
                minY: 0, // min Y-axis value
                maxY: 12, // max Y-axis value
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 2,
                  verticalInterval: 1, // this way we have a line per day
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
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) return Container();
                        return SideTitleWidget(
                          axisSide: meta.axisSide, // places the labels correctly (it passes the axis we are setting to correctly place the labels)
                          child: Text(
                            formatDate(days[index]), // labels set
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 40, // prevents the labels from getting cut off or squished by reserving enough vertical space below the chart
                    ),
                  ),
                  leftTitles: AxisTitles( // shows the titles on the left axis (Y-axis)
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (double value, TitleMeta meta) => Text(
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
                lineBarsData: [ // list of LineChartBarData objects (each one represents a single line on the chart)
                  LineChartBarData(
                    spots: spots, // List with index-duration (List of datapoints to be plotted)
                    isCurved: true, // smooth line
                    color: darkPurple,
                    barWidth: 3, // thickness of the line
                    isStrokeCapRound: true, // to round the ends of lines
                    dotData: FlDotData( // controls the appearance of the dots at each data point
                      show: true,
                      getDotPainter: (spot, percent, barData, index) { // custom function that tells fl_chart how to draw each dot individually
                                                                       // spot ---> the data point
                                                                       // percent ---> how far along the line this dot is (not used)
                                                                       // barData ---> the LineChartBarData instance
                                                                       // index ---> index of the point in the spots list
                        // Only show dot if this spot's y > 0 (meaningful data)
                        if (spot.y <= 0) {
                          return FlDotCirclePainter( // used to draw circular dots on chart lines
                            radius: 0, // zero radius = invisible dot
                            color: Colors.transparent,
                            strokeColor: Colors.transparent,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 5,
                          color: darkPurple, // fill color of the dot
                          strokeColor: Colors.white, // border color of the plot
                        );
                      },
                    ),

                    // belowBarData to create a shadow area under the line
                    belowBarData: BarAreaData( // configures the area under the line chart 
                      show: true,
                      color: darkPurple.withOpacity(0.25), // darkPurple color with transparency for shadow
                    ),
                  ),
                ],

                // Define how dots in the sleep chart respond to user touch and display tooltips
                lineTouchData: LineTouchData(
                  getTouchedSpotIndicator: // callback that defines how the indicator (highlight) should appear when the user touches a specific data point
                      // Function that takes the list of touched spotIndexes and transform each index into a widget or data structure that defines how the touch indicator looks for that specific data point
                      (barData, List<int> spotIndexes) => spotIndexes.map((index) { // neither barData nor spotIndexes are explicitly defined: they're parameters automatically passed by the fl_chart library when it calls that function
                                                                                    // barData ---> represents the entire dataset for the line chart that the user is interacting with and contains the info about the lines itself
                                                                                    // spotIndexes ---> list of integers, where each integer is an index of a data point that is currently "touched" or "highlighted" by the user
                            return TouchedSpotIndicatorData( // each touched spot index is converted into a TouchedSpotIndicatorData object ---> object describing how the touched spot should be rendered
                              FlLine(color: Colors.transparent), // vertical lines where the dot is active
                              FlDotData( // controls how to draw a dot at the touched spot
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
                          }).toList(), // converts the iterable of TouchedSpotIndicatorData into a List as expected by getTouchedSpotIndicator
                  touchTooltipData: LineTouchTooltipData( // to configure the tool tip that shows when the bar is active
                    tooltipBgColor: lilla,
                    getTooltipItems: (touchedSpots) { // function that generates the content shown when the bar is touched
                      return touchedSpots.map((spot) { // map to iterate
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
