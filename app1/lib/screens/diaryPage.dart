import 'package:flutter/material.dart';
import 'package:app1/screens/profilePage.dart';
import 'package:app1/widgets/my_drawer.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text('Trial App1'),),
        body: Center(child: Text('diaryPage'),),
    );
  }//build
}
