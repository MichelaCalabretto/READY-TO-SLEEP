import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app1/widgets/avatar_user.dart';

class Graph1 extends StatelessWidget {
  const Graph1({super.key});
@override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Avataruser(),
        const SizedBox(height: 20),
        Expanded(
          child: Stack(
            children: [
              // Bottone posizionato in alto
              Positioned(
                top: 120,
                left: 40,
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Azione del bottone
                      print("Button pressed!");
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      "SLEEP",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Grafico posizionato in basso e a larghezza piena
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0), // Spazio dal bordo inferiore
                  child: SizedBox(
                    width: double.infinity, // Larghezza massima
                    height: 300, // Altezza fissa
                    child: BarChart(
                      BarChartData(
                        // Inserisci qui i dati del grafico),
                    ),
                  ),
                ),
              ),
              ),
            ],
        ),
        ),
      ],
    
    );
  }
}
  
