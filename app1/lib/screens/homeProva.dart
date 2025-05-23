import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assicurati di avere provider
import 'package:app1/screens/profilePage.dart';
import 'package:app1/widgets/my_drawer.dart';
import 'package:app1/widgets/chart_switcher.dart'; // Assicurati che ChartSwitcher sia in questo file
import 'package:app1/providers/data_provider.dart'; // Importa il provider

class HomeProva extends StatefulWidget {
  HomeProva({Key? key}) : super(key: key);

  @override
  State<HomeProva> createState() => _HomeProvaState();
}

class _HomeProvaState extends State<HomeProva> {
  final Color darkPurple = const Color.fromARGB(255, 38, 9, 68); //reference color

  String sleepTrendStatus = '';
  String sleepNightStatus = '';

  // Esempio di date per la richiesta di trend (modifica con le date che ti servono)
  final String startDate = '2024-05-01';
  final String endDate = '2024-05-07';
  final String dayForNightData = '2024-05-07';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final sleepDataProvider = Provider.of<SleepDataProvider>(context, listen: false);

    // Provo a prendere i dati trend con range date
    try {
      await sleepDataProvider.fetchSleepTrendData(startDate, endDate);
      setState(() {
        sleepTrendStatus = 'Sleep trend data loaded successfully.';
      });
    } catch (e) {
      setState(() {
        sleepTrendStatus = 'Error loading sleep trend data: $e';
      });
    }

    // Provo a prendere i dati night per un giorno specifico
    try {
      await sleepDataProvider.fetchSleepNightData(dayForNightData);
      setState(() {
        sleepNightStatus = 'Sleep night data loaded successfully.';
      });
    } catch (e) {
      setState(() {
        sleepNightStatus = 'Error loading sleep night data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use extendBodyBehindAppBar to allow background image behind app bar and status bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Welcome to Flutter'),
        //backgroundColor: darkPurple.withOpacity(0.8), //semi-transparent to show background behind
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), //drawer icon color white
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawer: const MyDrawer(),
      body: Container(
        //make sure container takes full screen and image covers everything including behind system bars
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

              // Mostra lo stato delle chiamate API
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
              const ChartSwitcher(), // widget with graphs
            ],
          ),
        ),
      ),
    );
  }
}
