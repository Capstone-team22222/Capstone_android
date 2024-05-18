// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'shortcut.dart';
//
// class MainPage extends StatelessWidget{
//   const MainPage({super.key});
//
//   static const platform = MethodChannel('com.flutter_application_1.app/channel');
//
//
//   Future<void> _callNativeStartSleepTrackingFunction() async {
//     try {
//       final String result = await platform.invokeMethod('StartSleepTracking');
//     } on PlatformException catch (e) {
//       print("Failed to Invoke: '${e.message}'.");
//     }
//   }
//
//   Future<void> _callNativeStopSleepTrackingFunction() async {
//     try {
//       final String result = await platform.invokeMethod('StopSleepTracking');
//     } on PlatformException catch (e) {
//       print("Failed to Invoke: '${e.message}'.");
//     }
//   }
//
//   Future<void> _callNativeShowReportFunction() async {
//     try {
//       final String result = await platform.invokeMethod('GetReport');
//     } on PlatformException catch (e) {
//       print("Failed to Invoke: '${e.message}'.");
//     }
//   }
//
//   Future<void> _callNativeShowCurrentFunction() async {
//     try {
//       final String result = await platform.invokeMethod('ShowCurrent');
//     } on PlatformException catch (e) {
//       print("Failed to Invoke: '${e.message}'.");
//     }
//   }
//
//   Future<void> _callNativeShowTestFunction() async {
//     try {
//       final String result = await platform.invokeMethod('ShowTest');
//     } on PlatformException catch (e) {
//       print("Failed to Invoke: '${e.message}'.");
//     }
//   }
//
//
//
//
//
// // android에서 호출 -> 알람이 울림
//
//   static const MethodChannel methodChannel =  MethodChannel("myChannel");
//
//
//   Future<void> nativeMethodCallHandler(MethodCall methodCall) async {
//     print('알람 호출');
//     switch (methodCall.method) {
//       case "methodNameItz" :
//         AlarmHomeShortcutButton.global_key.currentState?.onPressButton(0);
//         break;
//       default:
//         print(' ... ');
//         break;
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 화면 중앙에 위치시킵니다.
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: _callNativeStartSleepTrackingFunction,
//               child: Text('측정 시작'),
//             ),
//             SizedBox(height: 20), // 버튼 사이의 간격을 주기 위해 SizedBox를 사용합니다.
//             ElevatedButton(
//               onPressed: _callNativeStopSleepTrackingFunction, // 측정 종료 함수를 호출합니다.
//               child: Text('측정 종료'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _callNativeShowReportFunction, // 리포트 보기 함수를 호출합니다.
//               child: Text('리포트'),
//             ),
//             ElevatedButton(
//               onPressed: _callNativeShowCurrentFunction,
//               child: Text('현재 상태'),
//             ),
//             ElevatedButton(
//               onPressed: _callNativeShowTestFunction,
//               child: Text('테스트'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/ring.dart';
import 'shortcut.dart';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'dart:async';



class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static const platform = MethodChannel('com.flutter_application_1.app/channel');

  Future<void> _callNativeStartSleepTrackingFunction() async {
    try {
      final String result = await platform.invokeMethod('StartSleepTracking');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  Future<void> _callNativeStopSleepTrackingFunction() async {
    try {
      final String result = await platform.invokeMethod('StopSleepTracking');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  Future<void> _callNativeShowReportFunction() async {
    try {
      final String result = await platform.invokeMethod('GetReport');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  Future<void> _callNativeShowCurrentFunction() async {
    try {
      final String result = await platform.invokeMethod('ShowCurrent');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  Future<void> _callNativeShowTestFunction() async {
    try {
      final String result = await platform.invokeMethod('ShowTest');
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  // android에서 호출 -> 알람이 울림
  static const MethodChannel methodChannel = MethodChannel("myChannel");

  @override
  Widget build(BuildContext context) {
    methodChannel.setMethodCallHandler(nativeMethodCallHandler);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 화면 중앙에 위치시킵니다.
          children: <Widget>[
            ElevatedButton(
              onPressed: _callNativeStartSleepTrackingFunction,
              child: Text('측정 시작'),
            ),
            SizedBox(height: 20), // 버튼 사이의 간격을 주기 위해 SizedBox를 사용합니다.
            ElevatedButton(
              onPressed: _callNativeStopSleepTrackingFunction, // 측정 종료 함수를 호출합니다.
              child: Text('측정 종료'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _callNativeShowReportFunction, // 리포트 보기 함수를 호출합니다.
              child: Text('리포트'),
            ),
            ElevatedButton(
              onPressed: _callNativeShowCurrentFunction,
              child: Text('현재 상태'),
            ),
            ElevatedButton(
              onPressed: _callNativeShowTestFunction,
              child: Text('테스트'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> nativeMethodCallHandler(MethodCall methodCall) async {

    switch (methodCall.method) {
      case "ring":
        print('알람 호출1');
        ringRing(DateTime.now().millisecondsSinceEpoch % 10000);

        break;


      default:
        print(' ... ');
        break;
    }
  }

  Future<void> ringRing(int num) async {
    int id = num;
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: DateTime.now(),
      assetAudioPath: 'marimba.mp3',
      volume: 1.0,
      notificationTitle: 'RingRing',
      notificationBody: '테스트',
    );
    await Alarm.set(alarmSettings: alarmSettings);




  }



}
