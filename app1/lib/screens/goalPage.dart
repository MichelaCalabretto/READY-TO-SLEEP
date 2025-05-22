import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app1/widgets/graph1.dart';

class GoalPage extends StatelessWidget {
  const GoalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Ready to sleep'),
        ),
        body: const TabBarView(
          children: <Widget>[
            Center(child: Graph1()),
            Center(child: Text("Pagina obiettivo da inserire")),
            
          ],
        ),
        bottomNavigationBar: const TabBar( 
          tabs: <Widget>[
            Tab(icon: Icon(Icons.home_outlined), text: 'Home',),
            Tab(icon: Icon(Icons.emoji_events), text: 'Goal',), 
          
          ],
        ),
      ),
    );
  }
}





//import 'package:flutter/material.dart';
//import 'package:app1/screens/profilePage.dart';
//import 'package:app1/widgets/my_drawer.dart';

//class GoalPage extends StatelessWidget {
  //GoalPage({Key? key}) : super(key: key);
  
  //@override
  //Widget build(BuildContext context){
    //return Scaffold(
        //appBar: AppBar(title: Text('Trial App1'),),
        //body: Center(child: Text('goalPage'),),
    //);
  //}//build
//}
