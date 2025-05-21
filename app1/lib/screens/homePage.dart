import 'package:flutter/material.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/widgets/my_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to Flutter'),),
      drawer: const MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'), // metti il percorso corretto
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'Hello World',
            style: TextStyle(
              color: Colors.white, // così si legge meglio sullo sfondo
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }//build
}



//abbiamo rimosso tutti i const sulle altre pagine, prob dopo la homePage dovrà avere un costruttore const, e quindi andranno tutti rimessi
//al momento rimane così per provare a runnare
