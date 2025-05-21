import 'package:flutter/material.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/widgets/custom_drawer.dart';

class GoalPage extends StatelessWidget {
  GoalPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text('Trial App1'),),
        body: Center(child: Text('goalPage'),),
    );
  }//build
}
