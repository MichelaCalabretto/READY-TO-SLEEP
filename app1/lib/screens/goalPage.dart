//import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';
//import 'package:app1/widgets/graph1.dart';
//import 'package:app1/screens/homePage.dart';

//class GoalPage extends StatelessWidget {
  //const GoalPage({Key? key}) : super(key: key);

  //@override
  //Widget build(BuildContext context) {
    //return DefaultTabController(
      //initialIndex: 1,
      //length: 2,
      //child: Scaffold(
        //appBar: AppBar(
          //title: const Text('Welcome to Ready to sleep'),
        //),
        //body: const TabBarView(
          //children: <Widget>[
            //Center(child: HomePage()),
            //Center(child: Graph1()),
            
          //],
        //),
        //bottomNavigationBar: const TabBar( 
          //tabs: <Widget>[
            //Tab(icon: Icon(Icons.emoji_events), text: 'Goal',), 
            //Tab(icon: Icon(Icons.home_outlined), text: 'Home',),
          //],
        //),
      //),
    //);
  //}
//}





import 'package:flutter/material.dart';
import 'package:app1/widgets/my_drawer.dart';

class GoalPage extends StatelessWidget {
  GoalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBodyBehindAppBar: true, // extend background behind app bar
      appBar: AppBar(
        title: const Text(
          'Welcome to Flutter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // transparent app bar
        elevation: 0,
        foregroundColor: Colors.white, // white text color matching profilePage
      ),
      drawer: const MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcomePage_wallpaper.png'), 
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Text(
            'goalPage',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  } // build
}
