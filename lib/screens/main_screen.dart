import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatelessWidget{
  const MainPage({super.key});
  static const platform = MethodChannel('com.example.myapp/native');

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '메인',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var result = await platform.invokeMethod('createInstance');
              },
              child: Text('버튼'),
            ),
          ],
        ),
      ),
    );
  }
}