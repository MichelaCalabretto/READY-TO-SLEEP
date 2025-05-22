import 'package:flutter/material.dart';
  
class Avataruser extends StatelessWidget{
  const Avataruser({super.key});  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('images/avatars/happy_dog.gif', height:180, width: 180,),
              
        const SizedBox(height: 12),
        const Text(
          'Benvenuto! Ecco il tuo andamento del sonno',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      const SizedBox(height: 25),
       const Text(
          'Questa notte hai dormito 8 ore',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      
      ],
    );
  }
}