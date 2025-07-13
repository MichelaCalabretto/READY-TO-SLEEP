import 'package:flutter/material.dart';
import 'package:app1/models/sleep_data_night.dart';
import 'package:fl_chart/fl_chart.dart';

class Graph1 extends StatefulWidget {
  // Input sleep data for the selected date
  final SleepDataNight? sleepData;

  const Graph1({Key? key, required this.sleepData}) : super(key: key);

  @override
  State<Graph1> createState() => _Graph1State();
}

class _Graph1State extends State<Graph1> {
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);
  final Color barColor = const Color.fromARGB(255, 38, 9, 68); 
  final Color backgroundWhiteShade = Colors.white70.withOpacity(0.2);
  final double barWidth = 22;

  // To keep track of which bar is currently touched
  int? touchedIndex;

  // Helper to convert minutes to hours (decimal)
  double minutesToHours(int minutes) => minutes / 60;

  // Helper to format duration in "X hours Y minutes"
  String formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h h $m m';
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.sleepData; // widget is how you access the properties of a StatefulWidget from its associated State class (_Graph1State)
                                   // sleepData is a parameter defined in the Graph1 widget class (which is the parent widget)
                                   // it basically pulls the current sleep data that was passed to this widget and stores it in the variable data to use it in the build method
    // In Flutter, when you use a StatefulWidget, you separate the widget definition (Graph1) from its state logic (_Graph1State) 
    // Since the state class doesn't automatically get direct access to the widget's constructor parameters (like sleepData), you must access them through the widget property

    // Check if data is null or all zero values (empty)
    bool noData = data == null ||
        (data.duration == 0 &&
         data.minutesToFallAsleep == 0 &&
         data.minutesAwake == 0 &&
         data.minutesRem == 0 &&  
         data.minutesDeep == 0 &&
         data.minutesLight == 0);

    if (noData) {
      // Show text message if no data available
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          'No sleep data available for the selected date.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Prepare data points for the bars
    // Each entry: [label, minutes]
    final sleepMetrics = <Map<String, dynamic>>[ // a List of Maps; each map has a String key (the label) and a value that can be any type (dynamic)
      // Each Mapm is composed by two key-value pairs: the first one is the label to be shown in the plot, the second one is the actual value to be plotted (the height of the bar)
      {'label': 'Duration', 'minutes': data.duration}, // here we are sure that data won't be null
      {'label': 'To Fall Asleep', 'minutes': data.minutesToFallAsleep},
      {'label': 'Awake', 'minutes': data.minutesAwake},
      {'label': 'REM', 'minutes': data.minutesRem},
      {'label': 'Deep', 'minutes': data.minutesDeep},
      {'label': 'Light', 'minutes': data.minutesLight},
    ];

    // Build bars with index and y-value in hours: a BarChartGroupData represents a group of bars that are drawn at the same x-axis position
    List<BarChartGroupData> barGroups = []; // list that holds the bars that are gonna be displayed (groups of just one bar in this case)
    for (int i = 0; i < sleepMetrics.length; i++) {
      final minutes = sleepMetrics[i]['minutes'] as int; // extraction of the value for the current metric
      final value = minutesToHours(minutes);
      barGroups.add(  // to add the bar to the list
        BarChartGroupData( // creates the bar
          x: i, // position of the bar
          barRods: [ // actual bars to show
            BarChartRodData( // the actual vertical bar drawn in the group
              toY: value,
              color: i == touchedIndex ? lilla : barColor, // if touched, the bar highlights in lilla, otherwise default color
              width: barWidth,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData( // background bar, which acts like a "shadow" or placeholder that visually shows the full height
                show: true,
                toY: 12, // max hours shown on background bar (12 hours)
                color: barColor.withOpacity(0.2),
              ),
            ),
          ],
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
              'Sleep Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded( // this way the widget will take all the aviable space
            child: BarChart( // to actually draw the bar chart (uses the configurations passed through BarChartData)
              BarChartData( // to configure the chart behaviour and appearance
                maxY: 12, // max 12 hours on Y axis
                minY: 0,
                barGroups: barGroups,
                gridData: FlGridData( // to control the grid lines in the background
                  show: true, // shows grid lines
                  drawHorizontalLine: true, // horizontal grid lines
                  horizontalInterval: 2, // horizontal grid lines every 2 hrs
                  getDrawingHorizontalLine: (value) => // defines the color and thickness of each grid line (value is the Y-value of the grid lines)
                      FlLine(color: Colors.white24, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false), // to hide the outer border of the chart
                
                // X and Y axis titles
                titlesData: FlTitlesData( // to configure the axes titles
                  bottomTitles: AxisTitles( // sets up the bottom axis (X-axis) of the chart
                    sideTitles: SideTitles( // configures the titles of the bottom axis (what is shown and how)
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) { // builder that dynamically returns the widget shown below each bar (the label) based on the bar's X index
                                                                        // value: the X-position of the bar
                                                                        // meta: metadata about where and how the label should appear ---> the label
                        final index = value.toInt(); // ATTENZIONE: here value is the position of the bar (from double value), not the minutes slept!!!!
                        if (index < 0 || index >= sleepMetrics.length) return Container(); // if the index is out of the boundaries, return an empty container
                        return SideTitleWidget( // actual widget to position axis labels
                          axisSide: meta.axisSide, // places the labels correctly (it passes the axis we are setting to correctly place the labels)
                          child: Text(
                            sleepMetrics[index]['label'], // actual label
                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold,),
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
                      getTitlesWidget: (double value, TitleMeta meta) { // function to build each label widget
                        return Text(
                          value.toInt().toString(), // convert the double (value) to an int and then to a String for display on the Y-axis
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold,),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                // Define how bars in the sleep chart respond to user touch and display tooltips
                barTouchData: BarTouchData( // to control how the bar behaves when the user taps it or pauses on it
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData( // to configure the tool tip that shows when the bar is active
                    tooltipBgColor: lilla, // tooltip background color
                    getTooltipItem: (group, groupIndex, rod, rodIndex) { // function that generates the content shown when the bar is touched
                      final metric = sleepMetrics[group.x.toInt()]; // "group.x" is the bar position ---> retrieves the metric (the Map) (REM, Deep, ...)
                      final minutes = metric['minutes'] as int;
                      final label = metric['label'];
                      final formatted = formatDuration(minutes);
                      return BarTooltipItem( // creates a BarTooltipItem widget, which defines what text and style the tooltip should have
                        '$label\n$formatted',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  // Handler that reacts when the user interacts with the chart
                  touchCallback: (event, response) { // event = information about the user's interaction
                                                     // response = contains info about what bar was touched, if any
                    setState(() { 
                      if (!event.isInterestedForInteractions || response == null || response.spot == null) { // checks if the event is interesting (user actually tapped or paused on the bar) and if there's a valid response with a touched spot
                                                                                                             // event.isInterestedForInteraction ---> tells whether the user's gesture (tap, press, hover) is considered meaningful or interesting for interacting with the chart
                                                                                                             // response.spot ---> the spot the user touched (it can become null if the user taps outside of the bar, so no actual bar spot is touched)
                        touchedIndex = null; // if the touch is not relevant or no spot is found 
                        return; // set touchedIndex = null to indicate no bar is selected
                      }
                      touchedIndex = response.spot!.touchedBarGroupIndex; // otherwise, update touchedIndex to the index of the touched bar group (here we are sure that the spot is not null ---> "!")
                                                                          // .touchedBarGroupIndex ---> gives the index of the bar group the user touched
                    });
                  },
                ),
                alignment: BarChartAlignment.spaceAround, // garantuees even spacing around each bar group
              ),
            ),
          ),
        ],
      ),
    );
  }
}
