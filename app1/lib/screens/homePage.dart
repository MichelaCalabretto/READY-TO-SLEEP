import 'package:flutter/material.dart';
import 'package:app1/utils/impact.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import 'package:app1/widgets/graphGoalPage.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Il Column occuperà l'intera altezza disponibile se Obiettivo è il body di uno Scaffold
    return Column(
      children: [
        const SizedBox(height: 25), // Spazio dall'alto
        Row( // Utilizzo un widget Row per affiancare testo e dropdown
          mainAxisAlignment: MainAxisAlignment.center, // Centra orizzontalmente il contenuto della riga
          children: [
            const Text(
              'Qual è il tuo obiettivo ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 10), // Spazio tra il testo e il dropdown
            const MenuOpzioni(), // Inserisco la classe MenuOpzioni qui
          ],
        ),
        // Spacer per spingere il grafico verso il centro
        const Spacer(),
        // Il grafico occuperà un terzo dell'altezza disponibile e larghezza piena
        SizedBox( // Usiamo SizedBox per controllare le dimensioni esatte del grafico
          width: double.infinity, // Larghezza massima disponibile
          //width: 300,
          // Calcola 1/3 dell'altezza totale dello schermo per il grafico
          height: 300,
          child: GraphGoalPage(), // Inseriamo il contenuto del grafico qui
        ),
        // Spacer per spingere il grafico verso il centro (bilancia lo Spacer superiore)
        const Spacer(flex: 3),
        const Padding(
          padding: EdgeInsets.only(bottom: 150.0, left: 16.0, right: 16.0), // Aggiungi padding per distanziare dai bordi
          child: Text(
            'Sono 7 giorni di fila che dormi bene',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center, // Centra il testo orizzontalmente
          ),
        ),
      ],
      
    );
  }
}

// La tua definizione di MenuOpzioni rimane invariata, ma l'ho inclusa per completezza
const List<String> list = <String>['6', '7', '8', '9'];

class MenuOpzioni extends StatefulWidget {
  const MenuOpzioni({super.key});

  @override
  State<MenuOpzioni> createState() => _MenuOpzioni();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _MenuOpzioni extends State<MenuOpzioni> {
  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  );
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: list.first,
      onSelected: (String? value) {
        // Quando l'user seleziona un valore
        setState(() {
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries: menuEntries,
    );
  }
}





//import 'package:flutter/material.dart';
//import 'package:app1/screens/profilePage.dart';
//import 'package:app1/widgets/my_drawer.dart';

//class HomePage extends StatelessWidget {
  //HomePage({Key? key}) : super(key: key);
  
  //@override
  //Widget build(BuildContext context){
    //return Scaffold(
      //appBar: AppBar(title: Text('Welcome to Flutter'),),
      //drawer: const MyDrawer(),
      //body: Container(
        //decoration: const BoxDecoration(
          //image: DecorationImage(
            //image: AssetImage('assets/images/welcomePage_wallpaper.png'), 
            //fit: BoxFit.cover,
          //),
        //),
        //child: const Center(
          //child: Text(
            //'Hello World',
            //style: TextStyle(
              //color: Colors.white, 
              //fontSize: 24,
              //fontWeight: FontWeight.bold,
            //),
          //),
        //),
      //),
    //);
  //}//build
//}



//abbiamo rimosso tutti i const sulle altre pagine, prob dopo la homePage dovrà avere un costruttore const, e quindi andranno tutti rimessi
//al momento rimane così per provare a runnare
