import 'package:flutter/material.dart';
import 'package:orilla_fresca_app/helpers/appcolors.dart';
import 'package:orilla_fresca_app/helpers/iconhelper.dart';
import 'package:orilla_fresca_app/helpers/utils.dart';
import 'package:orilla_fresca_app/services/loginservice.dart';
import 'package:orilla_fresca_app/widgets/iconfont.dart';
import 'package:orilla_fresca_app/widgets/themebutton.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned.fill( //wallpaper image
              child: Opacity( //to make the wallpaper image transparent 
                opacity: 0.3,
                child: Image.asset(
                'assets/imgs/of_main_bg.png', //IMAGE TO CHANGE
                fit: BoxFit.cover),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, //centers horizontally
                crossAxisAlignment: CrossAxisAlignment.stretch, //centers vertically
                children: [
                  Center(
                    child: ClipOval( //oval logo
                      child: Container(
                        width: 180,
                        height: 180,
                        color: AppColors.MAIN_COLOR,
                        alignment: Alignment.center,
                        child: IconFont(
                          iconName: IconFontHelper.MAIN_LOGO,
                          color: Colors.white,
                          size: 130
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Text('Welcome to', //DA SISTEMARE
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  SizedBox(height: 40),
                  Text('Productos Frescos.\nSaludables. A Tiempo', //DOVE DOBBIAMO SCRIVERE IL NOSTRO PARAGRAFETTO
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18
                    )
                  ),
                  SizedBox(height: 40),


                  //NOSTRO BOTTONE
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => LoginPage()));
                      }
                      child: Text(
                        'Login',
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      )
    );
  }
}