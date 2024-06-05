import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ring.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SleepingScreenState();
}

class _SleepingScreenState extends State<SleepingScreen> {
  int _alarmTimestamp, _timeLeft;
  String _soundName = "Ring";
  StreamSubscription _sub;

  void setUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _alarmTimestamp =
        prefs.getInt("alarm") ?? DateTime.now().millisecondsSinceEpoch;
    _soundName = prefs.getString("sound") ?? "Ring";

    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    int timeLeft = _alarmTimestamp - currentTimestamp;

    scheduleNotification(timeLeft);
    print(timeLeft);
    CountdownTimer countdownTimer =
    CountdownTimer(Duration(milliseconds: timeLeft), Duration(seconds: 1));
    _sub = countdownTimer.listen(null);
    _sub.onData((duration) {
      timeLeft -= 1000;

      this.onTimerTick(timeLeft);
      print('Counting down: $timeLeft');
    });

    _sub.onDone(() {
      print("Done.");
      _sub.cancel();
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AlarmRingScreen(alarmSettings: alarmSettings),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          )
      );
    });
  }

  void onTimerTick(int newTimestamp) {
    setState(() {
      _timeLeft = newTimestamp;
    });
  }
  
  @override
  void initState() {
    super.initState();
    _timeLeft = 0;
    setUp();
  }

  @override
  Widget build(BuildContext context) {
    final _cancelButton = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            flutterLocalNotificationsPlugin.cancelAll();
            Navigator.pop(context);
          });
        },
        child: Text("취소",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            )
        ),
      ),
    );

    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "남은 수면 시간:",
                style:
                TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                formatHMS((_timeLeft / 1000).round()),
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 40,
              ),
              _cancelButton,
            ],
          )
      ),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
