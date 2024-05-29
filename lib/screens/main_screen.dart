import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatelessWidget{
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

  @override
  Widget build(BuildContext context) {
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
            )
          ],
        ),
      ),
    );
  }



// @override
  // Widget build(BuildContext context){
  //   return Scaffold(
  //     body: Center(
  //       //child: Text('메인', style: Theme.of(context).textTheme.titleMedium,),
  //       child: ElevatedButton(
  //       onPressed: _callNativeStartSleepTrackingFunction,
  //       child: Text('측정 시작'),
  //   ),
  //     )
  //   );
  // }
}