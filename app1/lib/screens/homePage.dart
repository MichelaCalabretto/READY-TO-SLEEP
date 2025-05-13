import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text('Welcome to Flutter'),),
        body: Center(child: Text('Hello World'),)
    );
}//build
}


//abbiamo rimosso tutti i const sulle altre pagine, prob dopo la homePage dovrà avere un costruttore const, e quindi andranno tutti rimessi
//al momento rimane così per provare a runnare
