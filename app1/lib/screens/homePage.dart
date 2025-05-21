import 'package:flutter/material.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text('Welcome to Flutter'),),
        body: Center(child: Text('Hello World'),),
        drawer: const MyDrawer(),
        //drawer: Drawer(
          //child: ListTile(
            //leading: Icon(Icons.person),
            //title: Text('Profile'),
            //onTap: () {
              //Navigator.pop(context); // chiude il drawer
              //Navigator.push(
                //context,
                //MaterialPageRoute(builder: (context) => ProfilePage()),
              //);
            //},
          //),
        //),
    );
  }//build
}


//abbiamo rimosso tutti i const sulle altre pagine, prob dopo la homePage dovrà avere un costruttore const, e quindi andranno tutti rimessi
//al momento rimane così per provare a runnare
