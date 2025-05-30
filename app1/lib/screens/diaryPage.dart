import 'package:flutter/material.dart';
import 'package:app1/widgets/my_drawer.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage({Key? key}) : super(key: key);
  
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
            'diaryPage',
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
