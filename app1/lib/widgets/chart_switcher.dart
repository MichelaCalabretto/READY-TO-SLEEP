import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import per Provider
import 'package:app1/models/sleep_data_night.dart'; // Assicurati che il percorso sia corretto
import 'package:app1/models/sleep_data_trend.dart'; // Assicurati che il percorso sia corretto
import 'package:app1/providers/data_provider.dart'; // Assicurati che il percorso sia corretto per il tuo SleepDataProvider
import 'dart:math';

class ChartSwitcher extends StatefulWidget {
  // Rimuoviamo i campi final sleepDataNights e sleepDataTrends
  // in quanto i dati verranno ottenuti direttamente dal Provider.
  const ChartSwitcher({
    Key? key,
  }) : super(key: key);

  @override
  _ChartSwitcherState createState() => _ChartSwitcherState();
}

class _ChartSwitcherState extends State<ChartSwitcher> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Color themePurple = const Color.fromARGB(255, 38, 9, 68);
  final Color chartBgColor = Colors.white70;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().subtract(const Duration(days: 1));
    // Richiamiamo la funzione per caricare i dati all'inizializzazione del widget,
    // dopo che il build è stato completato e il context è disponibile.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataForSelectedDate();
    });
  }

  // Funzione per richiamare il fetching dei dati dal Provider
  void _fetchDataForSelectedDate() async {
    // Ottieni l'istanza del provider senza ascoltare i cambiamenti (listen: false)
    // perché lo useremo solo per chiamare i metodi di fetching.
    final sleepProvider = Provider.of<SleepDataProvider>(context, listen: false);

    // Formatta la data per le chiamate API
    final String dayForNight = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String startDateForTrend = DateFormat('yyyy-MM-dd').format(selectedDate.subtract(const Duration(days: 6)));
    final String endDateForTrend = DateFormat('yyyy-MM-dd').format(selectedDate);

    await sleepProvider.fetchSleepNightData(dayForNight);
    await sleepProvider.fetchSleepTrendData(startDateForTrend, endDateForTrend);
  }

  // I getter ora prenderanno i dati dall'istanza del provider passata
  // nel metodo build tramite Consumer o Provider.of.
  // Ho trasformato i getter in funzioni che accettano le liste complete dal provider.
  List<SleepDataNight> _getFilteredSleepDataNights(List<SleepDataNight> allNightData) {
    return allNightData.where((data) {
      return data.time.year == selectedDate.year &&
          data.time.month == selectedDate.month &&
          data.time.day == selectedDate.day;
    }).toList();
  }

  List<SleepDataTrend> _getFilteredSleepDataTrends(List<SleepDataTrend> allTrendData) {
    final startDate = selectedDate.subtract(const Duration(days: 6));
    return allTrendData.where((data) {
      return !data.time.isBefore(startDate) &&
             !data.time.isAfter(selectedDate);
    }).toList();
  }

  String get chartTitle {
    return _currentIndex == 0 ? "Tonight's Recap" : "7-Day Trend";
  }

  // Le funzioni _buildBarChart e _buildLineChart ora accetteranno
  // i dati filtrati come parametro.
  Widget _buildBarChart(List<SleepDataNight> filteredData) {
    if (filteredData.isEmpty) {
      return const Center(
        child: Text(
          'No night data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final data = filteredData.first;
    // Usiamo direttamente i campi senza '?? 0' perché SleepDataNight.fromJson
    // gestisce già i valori nulli e li imposta a 0.
    final deepHours = data.deepMinutes / 60;
    final lightHours = data.lightMinutes / 60;
    final remHours = data.remMinutes / 60;

    final maxY = [deepHours, lightHours, remHours].reduce(max).ceilToDouble();

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: chartBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(toY: deepHours, color: themePurple, width: 20)
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: lightHours, color: themePurple, width: 20)
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: remHours, color: themePurple, width: 20)
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Deep', style: TextStyle(fontSize: 12));
                    case 1:
                      return const Text('Light', style: TextStyle(fontSize: 12));
                    case 2:
                      return const Text('REM', style: TextStyle(fontSize: 12));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}h',
                      style: const TextStyle(fontSize: 12));
                },
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          maxY: maxY > 0 ? maxY + 1 : 5, // Add some padding
        ),
      ),
    );
  }

  Widget _buildLineChart(List<SleepDataTrend> filteredData) {
    if (filteredData.isEmpty) {
      return const Center(
        child: Text(
          'No trend data available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final spots = filteredData.map((data) {
      final daysFromStart = data.time
          .difference(selectedDate.subtract(const Duration(days: 6)))
          .inDays
          .toDouble();
      return FlSpot(daysFromStart, data.duration / 60); // Convert to hours
    }).toList();

    // Ordina i punti per x per garantire la corretta visualizzazione nel LineChart
    spots.sort((a, b) => a.x.compareTo(b.x));

    // Determina min/max Y per il grafico in base ai dati effettivi
    double minY = spots.isNotEmpty ? spots.map((e) => e.y).reduce(min) : 0;
    double maxY = spots.isNotEmpty ? spots.map((e) => e.y).reduce(max) : 5;

    // Aggiungi un po' di padding e assicurati un intervallo ragionevole di default
    minY = (minY - 1).floorToDouble();
    if (minY < 0) minY = 0;
    maxY = (maxY + 1).ceilToDouble();
    if (maxY <= 1) maxY = 5; // Assicurati un intervallo minimo


    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: chartBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6, // Sempre 7 giorni (0-6)
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: themePurple,
              barWidth: 4,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date =
                      selectedDate.subtract(Duration(days: 6 - value.toInt()));
                  return Text(DateFormat('E').format(date),
                      style: const TextStyle(fontSize: 12));
                },
                reservedSize: 32,
                interval: 1, // Mostra i titoli per ogni giorno
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}h',
                      style: const TextStyle(fontSize: 12));
                },
                reservedSize: 40,
                interval: 1, // Mostra le etichette delle ore intere
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usa Consumer per accedere ai dati forniti da SleepDataProvider e reagire ai cambiamenti.
    return Consumer<SleepDataProvider>(
      builder: (context, sleepProvider, child) {
        // Ottieni i dati più recenti dal provider e poi filtrali.
        final filteredSleepDataNights = _getFilteredSleepDataNights(sleepProvider.nightData);
        final filteredSleepDataTrends = _getFilteredSleepDataTrends(sleepProvider.trendData);

        return Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(DateFormat.yMMMd().format(selectedDate)),
            ),
            const SizedBox(height: 8),
            Text(chartTitle, style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 16),
            SizedBox(
              height: 350, // Fixed height for the chart area
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                // Passa i dati filtrati alle funzioni di costruzione del grafico
                children: [
                  _buildBarChart(filteredSleepDataNights),
                  _buildLineChart(filteredSleepDataTrends)
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [0, 1].map((i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == i ? 12 : 8,
                height: _currentIndex == i ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == i ? Colors.white : Colors.white54,
                ),
              )).toList(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _fetchDataForSelectedDate(); // Richiama il fetching dei dati per la nuova data
      });
    }
  }
}