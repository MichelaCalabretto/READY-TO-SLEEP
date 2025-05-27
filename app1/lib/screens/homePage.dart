/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/widgets/my_drawer.dart'; // Assicurati che il percorso sia corretto
import 'package:app1/widgets/chart_switcher.dart'; // Assicurati che il percorso sia corretto
import 'package:app1/providers/data_provider.dart'; // Assicurati che il percorso sia corretto

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68);

  // Questi stati non sono più strettamente necessari per indicare lo stato
  // del caricamento dati sui grafici, in quanto il ChartSwitcher si aggiornerà
  // autonomamente tramite il Consumer. Potrebbero essere usati per indicare
  // lo stato generale del fetch dati della pagina.
  String sleepTrendStatus = '';
  String sleepNightStatus = '';

  @override
  void initState() {
    super.initState();
    // Richiamiamo il fetching dei dati.
    // L'uso di `WidgetsBinding.instance.addPostFrameCallback` è una buona pratica
    // per assicurarsi che il `context` sia completamente disponibile prima di chiamare `Provider.of`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    // Ottieni l'istanza del provider. listen: false è cruciale qui
    // perché siamo in initState/un callback e non vogliamo ricostruire il widget.
    final sleepDataProvider = Provider.of<SleepDataProvider>(context, listen: false);

    // Calculate latest available date (yesterday)
    final DateTime today = DateTime.now();
    // Assicurati che la data sia corretta per i tuoi scopi (ad esempio, l'inizio del giorno)
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
      drawer: const MyDrawer(), // Assicurati che MyDrawer sia importato correttamente
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
            //padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
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
                // Qui non abbiamo più bisogno del Consumer per ChartSwitcher
                // perché ChartSwitcher è già un Consumer al suo interno.
                // Lo chiamiamo semplicemente senza passare i dati.
                const ChartSwitcher(), // Chiamata modificata
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app1/widgets/my_drawer.dart';
import 'package:app1/widgets/chart_switcher.dart';
import 'package:app1/providers/data_provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _loadingStatus = 'Loading data...'; // Stato unificato per entrambi i fetch

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    final provider = Provider.of<SleepDataProvider>(context, listen: false);
    final yesterday = _getYesterday();

    try {
      setState(() => _loadingStatus = 'Loading sleep data...');
      
      // Esegui i fetch in parallelo
      await Future.wait([
        provider.fetchSleepTrendData(
          _formatDate(yesterday.subtract(const Duration(days: 6))), 
          _formatDate(yesterday),
          
        ),
        provider.fetchSleepNightData(_formatDate(yesterday)),
      ]);

      setState(() => _loadingStatus = 'Data loaded successfully');
    } catch (e) {
      setState(() => _loadingStatus = 'Error loading data: ${e.toString()}');
      debugPrint('Error fetching data: $e');
    }
  }

  DateTime _getYesterday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your Sleep Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
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
              ),

              // Status message
              Text(
                _loadingStatus,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Content with loading state
              Expanded(
                child: _loadingStatus.contains('successfully')
                    ? const ChartSwitcher()
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}