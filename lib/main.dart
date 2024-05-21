import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alarm/alarm.dart';

import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/alarm_screen.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Alarm.init(showDebugLogs: true);
  
  runApp(const MyApp());
  runApp(const MyScreen());

  
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int currentIndex = 0;
  final screens = [
    const MainPage(),
    const AlarmPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xffe9edf3),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(223, 193, 236, 1),
          leading: IconButton(
            onPressed: (){},
            icon: const Icon(Icons.sunny, size: 30),
            padding: const EdgeInsets.only(left: 120)
            ),
          title: const Text(
            "수면 추적",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: screens[currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          buttonBackgroundColor: const Color.fromRGBO(223, 193, 236, 1),
          color: const Color.fromRGBO(223, 193, 236, 1),
          animationDuration: const Duration(milliseconds: 300),          
          // currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          items: const <Widget>[
            Icon(Icons.home, size: 36, color: Colors.white),
            Icon(Icons.alarm, size: 36, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class MyScreen extends StatelessWidget{
  const MyScreen({super.key});
  
  @override 
  Widget build(BuildContext context){
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
