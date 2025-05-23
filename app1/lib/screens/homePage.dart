//import 'package:flutter/material.dart';
//import 'package:app1/utils/impact.dart';
//import 'package:fl_chart/fl_chart.dart';
//import 'package:collection/collection.dart';
//import 'package:app1/widgets/graphGoalPage.dart';


//class HomePage extends StatelessWidget {
  //const HomePage({super.key});

  //@override
  //Widget build(BuildContext context) {
    //return Scaffold(  
      //body: Column(
        //children: [
          //const SizedBox(height: 25),
          //Row(
            //mainAxisAlignment: MainAxisAlignment.center,
            //children: [
              //const Text(
                //'Qual è il tuo obiettivo ?',
                //style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                //textAlign: TextAlign.center,
              //),
              //const SizedBox(width: 10),
              //const MenuOpzioni(),
            //],
          //),
          //const Spacer(),
          //SizedBox(
            //width: double.infinity,
            //height: 300,
            //child: GraphGoalPage(),
          //),
          //const Spacer(flex: 3),
          //const Padding(
            //padding: EdgeInsets.only(bottom: 150.0, left: 16.0, right: 16.0),
            //child: Text(
              //'Sono 7 giorni di fila che dormi bene',
              //style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              //textAlign: TextAlign.center,
            //),
          //),
        //],
      //),
    //);
  //}
//}


// La tua definizione di MenuOpzioni rimane invariata, ma l'ho inclusa per completezza
//const List<String> list = <String>['6', '7', '8', '9'];

//class MenuOpzioni extends StatefulWidget {
  //const MenuOpzioni({super.key});

  //@override
  //State<MenuOpzioni> createState() => _MenuOpzioni();
//}

//typedef MenuEntry = DropdownMenuEntry<String>;

//class _MenuOpzioni extends State<MenuOpzioni> {
  //static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    //list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  //);
  //String dropdownValue = list.first;

  //@override
  //Widget build(BuildContext context) {
    //return DropdownMenu<String>(
      //initialSelection: list.first,
      //onSelected: (String? value) {
        // Quando l'user seleziona un valore
        //setState(() {
          //dropdownValue = value!;
        //});
      //},
      //dropdownMenuEntries: menuEntries,
    //);
  //}
//}





import 'package:flutter/material.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/widgets/my_drawer.dart';
import 'package:app1/widgets/chart_switcher.dart'; // Assicurati che ChartSwitcher sia in questo file

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final Color darkPurple = Color.fromARGB(255, 38, 9, 68); //reference color

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
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const ChartSwitcher(), // widget with graphs
            ],
          ),
        ),
      ),
    );
  } //build
}





//abbiamo rimosso tutti i const sulle altre pagine, prob dopo la homePage dovrà avere un costruttore const, e quindi andranno tutti rimessi
//al momento rimane così per provare a runnare
