import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/widgets/my_drawer.dart';
import 'package:app1/widgets/chart_switcher.dart';
import 'package:app1/providers/data_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);

  String sleepTrendStatus = '';
  String sleepNightStatus = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final sleepDataProvider = Provider.of<SleepDataProvider>(context, listen: false);

    // Calculate latest available date (yesterday)
    final DateTime today = DateTime.now();
    final DateTime latestDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));

    // For trend data, get 7 days including latestDate
    final DateTime startDate = latestDate.subtract(const Duration(days: 6));
    final String startDateStr = _formatDate(startDate);
    final String endDateStr = _formatDate(latestDate);
    final String nightDateStr = endDateStr; // latest night date for night data

    try {
      await sleepDataProvider.fetchSleepTrendData(startDateStr, endDateStr);
      setState(() {
        sleepTrendStatus = 'Sleep trend data loaded successfully.';
      });
    } catch (e) {
      setState(() {
        sleepTrendStatus = 'Error loading sleep trend data: $e';
      });
    }

    try {
      await sleepDataProvider.fetchSleepNightData(nightDateStr);
      setState(() {
        sleepNightStatus = 'Sleep night data loaded successfully.';
      });
    } catch (e) {
      setState(() {
        sleepNightStatus = 'Error loading sleep night data: $e';
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Welcome to Flutter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawer: const MyDrawer(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Hello World',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  sleepTrendStatus,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  sleepNightStatus,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Consumer<SleepDataProvider>(
                  builder: (context, provider, _) {
                    return ChartSwitcher(
                      sleepDataTrends: provider.trendData,
                      sleepDataNights: provider.nightData,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}