import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});

  @override 
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {

@override
void initState(){
  super.initState();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);  

  Future.delayed(const Duration(seconds: 2), (){
  Navigator.of(context).pushReplacement(MaterialPageRoute(
    builder: (_) => const MyApp(),
  ));
});
}



@override
void dispose(){
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
super.dispose();
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(223, 193, 236, 1)
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nights_stay_rounded,
            size: 80,
            color: Colors.white,),
            SizedBox(height: 20,
              ),
              Text('Sleep Tracker', 
              style: TextStyle(fontSize: 30, fontStyle:  FontStyle.italic, color: Colors.white)
            )
          ],
          )
      ),
    );
  }
}