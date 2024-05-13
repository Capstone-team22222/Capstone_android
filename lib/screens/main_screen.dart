import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';

import 'ring.dart';


import 'package:flutter/material.dart';

class MainPage extends StatefulWidget{
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage>{
  late List<AlarmSettings> alarms;
  List<bool> _alarmOnOff = [];
  static StreamSubscription<AlarmSettings>? subscription;

  //@override
  //void initState() {
    //super.initState();
    //loadAlarms();
    //subscription ??= Alarm.ringStream.stream.asBroadcastStream().listen(
      //(alarmSettings) => navigateToRingScreen(alarmSettings),
    //);
  //}

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      for (int i = 0; i < alarms.length; i++) {
        if (alarms[i].dateTime.year == 2050) {
          _alarmOnOff.add(false);
        } else {
          _alarmOnOff.add(true);
        }
      }
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              AlarmRingScreen(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(child: Text('메인', style: Theme.of(context).textTheme.titleMedium,),
      ),
    );
  }
}