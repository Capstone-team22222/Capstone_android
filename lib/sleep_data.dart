import 'package:http/http.dart' as http;
import 'dart:convert';

//Data API sleep time 그래프 표현에 필요한 변수
class SleepData {
  final String sessionId;
  final String state;
  final DateTime startTime;
  final DateTime endTime;

  final DateTime sleepTime;
  final DateTime wakeTime;


  SleepData({
    required this.sessionId,
    required this.state,
    required this.startTime,
    required this.endTime,
    required this.sleepTime,
    required this.wakeTime,

  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      sessionId: json['result']['session']['id'],
      state: json['result']['session']['state'],
      startTime: json['result']['session']['start_time'],
      endTime: json['result']['session']['end_time'],
      sleepTime: DateTime.parse(json['result']['stat']['sleep_time']),
      wakeTime: DateTime.parse(json['result']['stat']['wake_time']),


    );
  }
}


Future<void> fetchData(String sessionId, String apiKey, String userId) async { // 사용자의 세션 데이터를 API로부터 받아와서 처리하는 작업
  final String apiUrl = "https://api.asleep.ai/data/v3/sessions/$sessionId";

  final response = await http.get(
    Uri.parse(apiUrl), // apiUrl을 Uri 객체로 변환
    headers: {
      "x-api-key": apiKey,
      "x-user-id": userId,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final sleepData = SleepData.fromJson(jsonResponse);
    print("Session ID: ${sleepData.sessionId}");
    print("Start Time: ${sleepData.startTime}");
    print("End Time: ${sleepData.endTime}");
  } else if (response.statusCode == 400) {
    // 클라 요청 오류
    final error = json.decode(response.body);
    if (error['detail'] == "The invalid timezone is provided") {
      print("Bad request: Invalid timezone");
    } else if (error['detail'] == "The format of x-user-id is invalid") {
      print("Bad request: Invalid x-user-id format");
    } else if (error['detail'].startsWith("The format of sleep session id")) {
      print("Bad request: Invalid session id format");
    } else {
      print("Bad request: ${response.body}");
    }
  } else if (response.statusCode == 404) {
    // 리소스 찾을 수 없음
    final error = json.decode(response.body);
    print("Not found: ${response.statusCode}");
    print("Error message: ${error['detail']}");
  } else {
    // 기타 오류
    print("Failed to fetch data: ${response.statusCode}");
  }
} //수면 데이터 받아오는 코드
