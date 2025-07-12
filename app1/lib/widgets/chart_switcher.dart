import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:app1/providers/data_provider.dart'; 
import 'package:app1/widgets/graph1.dart'; 
import 'package:app1/widgets/graph2.dart'; 

class ChartSwitcher extends StatefulWidget {
  const ChartSwitcher({Key? key}) : super(key: key);

  @override
  State<ChartSwitcher> createState() => _ChartSwitcherState();
}

class _ChartSwitcherState extends State<ChartSwitcher> {
  final PageController _pageController = PageController(); // controller for swiping between charts (for PageView)
  int _currentPage = 0; // currently selected page index (0 = Graph1, 1 = Graph2)
  late DateTime _selectedDate; // selected date by the user, default to yesterday
                               // late means that the variable will be initialized later on, and not here

  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);
  final Color lilla = const Color.fromARGB(255, 192, 153, 227);
  final Color whiteShade = Colors.white70;
  final Color whiteStrong = Colors.white;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().subtract(const Duration(days: 1)); // default: yesterday
    // addPostFrameCallback to avoid calling async during initState build cycle
    // This way first the UI finishes building and rendering, and only then the data is fetched and displayed in the chart through notifyListeners() inside the provider
    WidgetsBinding.instance.addPostFrameCallback((_) { // method that schedules a callback to be run after the current frame is rendered, meaning after the widget tree has been built and laid out on screen
                                                       // WidgetsBinding.instance ---> gives you access to the Flutter widget system's event loop
                                                       // .addPostFrameCallback(...) ---> registers a function that will run after the current frame
      _fetchDataForDate(_selectedDate);
    });
  }

  // Helper to format date as "MMM d, yyyy" (i.e., May 28, 2025)
  String _formatFullDate(DateTime date) { // format to show on the date button
    return DateFormat('MMM d, yyyy').format(date);
  }

  // Compute startDate for 7-day range ending at endDate
  String _computeStartDate(DateTime endDate) { // to extract the startDate from the endDate to give in input to the fetchSleepTrendData
    final startDate = endDate.subtract(const Duration(days: 6));
    return DateFormat('yyyy-MM-dd').format(startDate);
  }

  // Format date as yyyy-MM-dd string (API format)
  String _formatDateForApi(DateTime date) { // format for fetchData methods
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Fetch trend and night data for the selected date
  Future<void> _fetchDataForDate(DateTime date) async {
    final provider = context.read<SleepDataProvider>(); // to get an instance of the SleepDataProvider from the current widget context (to then call the fetchData methods defined in the provider)
                                                        // context.read<T>() to access the provider without listening to changes (since I'm just fetching the data here)

    final endDateStr = _formatDateForApi(date); // computes the dates in the right format for the API request
    final startDateStr = _computeStartDate(date);

    // The sleepData is fetched and saved inside the provider's internal state
    await provider.fetchSleepTrendData(startDateStr, endDateStr); // fetch sleep trend data for 7 days ending at selected date
    await provider.fetchSleepNightData(endDateStr);  // fetch detailed night data for the selected date (fullDate)
  }

  // Show date picker dialog, limited up to yesterday
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final picked = await showDatePicker( // dialog that displays a calendar to let the user pick a date
      context: context,
      initialDate: _selectedDate, // initial date: date selected on default when the data picker opens
      firstDate: DateTime(2020), // first date aviable for picking
      lastDate: yesterday,
      builder: (context, child) { // to customize the calendar dialog appearance (child is the calendar shown)
        // Light theme inside the calendar with darkPurple text and lilla highlight on selected day
        return Theme( // creates a new Theme for the date picker only, based on the current theme, but modified
          data: Theme.of(context).copyWith( // Theme.of(context) ---> the current theme of the calendar
                                            // .copyWith ---> allows to make changes to the current theme (you can't change directly the theme, you need to make a copy with the modifications)
            colorScheme: ColorScheme.light( // creates a light-themed color palette
              primary: lilla, // selected day background
              onPrimary: whiteStrong, // selected day text color
              onSurface: darkPurple, // unselected day text color
              surface: whiteStrong, // background of the calendar
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: darkPurple, // cancel/confirm buttons color
              ),
            ),
          ),
          child: child!, // after applying a new Theme to the dialog UI, we need to return that same dialog as a child
                         // ! because here we are shure that it is not null
        );
      },
    );

    // If the selected date changed, fetch the new sleepData
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Delaye the UI rebuild until the animation is completed
      Future.delayed(Duration.zero, () {
        _fetchDataForDate(picked);
      });
    }
  }

  // Widget for the date picker button above the charts
  Widget _buildDatePickerButton() {
    return Align(
      alignment: Alignment.centerRight, 
      child: ElevatedButton.icon(
        onPressed: _pickDate,
        icon: Icon(Icons.calendar_today, color: darkPurple),
        label: Text(
          _formatFullDate(_selectedDate),
          style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteStrong, // white button background
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 0,
        ),
      ),
    );
  }

  // Dot indicators for the current page under the charts
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) { // generates a list of two widgets, one per page; index is the index of the page (0 or 1)
        bool isActive = index == _currentPage;
        return AnimatedContainer( // animation for the dots
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6), // space between the dots
          width: isActive ? 14 : 10, // to change the dimension of the dot when active
          height: isActive ? 14 : 10,
          decoration: BoxDecoration(
            color: isActive ? lilla : whiteShade, // highlight with lilla, inactive dots whiteShade
            shape: BoxShape.circle, // dot shape
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to SleepDataProvider for data updates (wrap the chart_switcher inside a consumer)
    return Consumer<SleepDataProvider>(
      builder: (context, provider, _) {
        // Pass data to Graph widgets
        final trendData = provider.sleepTrendData;
        final nightData = provider.sleepNightData;

        return Container(
          padding: const EdgeInsets.all(16), // padding all around
          // Transparent background 
          color: Colors.transparent,
          // LayoutBuilder to dynamically adapt height based on screen constraints
          child: LayoutBuilder( // LayoutBuilder  lets you access the size constraints (i.e. max height/width) of the parent widget at build time
            builder: (context, constraints) {
              double chartHeight = constraints.maxHeight * 0.7; // allocates 70% of available height to the chart area
                                                                // constraints.maxHeight is the maximum height the widget can use ---> the chart_switcher is set to take 70% of the maxHeight
              return Column(
                mainAxisSize: MainAxisSize.min, // so that the column will take only the minimum space needed, based on its children
                children: [
                  _buildDatePickerButton(),
                  const SizedBox(height: 12),

                  // Swipeable charts area
                  SizedBox(
                    height: chartHeight,
                    child: PageView( // widget to swipe horizontally between the two charts
                      controller: _pageController, // page visible at the moment
                      onPageChanged: (page) { // everytime the page changes, the _currentPage will be changed conseguentely
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        // Graph1 expects SleepDataNight for a single night
                        Graph1(
                          sleepData: nightData,
                        ),
                        // Graph2 expects List<SleepDataTrend> for the week
                        Graph2(
                          trendData: trendData,
                          endDate: _selectedDate,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Page indicator dots
                  _buildPageIndicator(),
                ],
              );
            }
          ),
        );
      },
    );
  }
}
