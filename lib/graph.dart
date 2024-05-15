import 'package:http/http.dart' as http;
import 'dart:convert';


class SleepData {
  final String sessionId;
  final String state;
  final String startTime;
  final String endTime;
  final List<int> sleepStages;
  final List<int> breathStages;
  final List<int> snoringStages;
  final DateTime sleepTime;
  final DateTime wakeTime;
  final int sleepIndex;
  final int sleepLatency;
  final int wakeupLatency;
  final int lightLatency;
  final int deepLatency;
  final int remLatency;
  final int timeInBed;
  final int timeInSleepPeriod;
  final int timeInSleep;
  final int timeInWake;
  final int timeInLight;
  final int timeInDeep;
  final int timeInRem;
  final int timeInStableBreath;
  final int timeInUnstableBreath;
  final int timeInSnoring;
  final int timeInNoSnoring;
  final double sleepEfficiency;
  final double sleepRatio;
  final double wakeRatio;
  final double lightRatio;
  final double deepRatio;
  final double remRatio;
  final double stableBreathRatio;
  final double unstableBreathRatio;
  final double snoringRatio;
  final double noSnoringRatio;
  final double breathingIndex;
  final String breathingPattern;
  final int wasoCount;
  final int longestWaso;
  final int sleepCycleCount;
  final int sleepCycle;
  final List<String> sleepCycleTime;
  final int unstableBreathCount;
  final int snoringCount;

  SleepData({
    required this.sessionId,
    required this.state,
    required this.startTime,
    required this.endTime,
    required this.sleepStages,
    required this.breathStages,
    required this.snoringStages,
    required this.sleepTime,
    required this.wakeTime,
    required this.sleepIndex,
    required this.sleepLatency,
    required this.wakeupLatency,
    required this.lightLatency,
    required this.deepLatency,
    required this.remLatency,
    required this.timeInBed,
    required this.timeInSleepPeriod,
    required this.timeInSleep,
    required this.timeInWake,
    required this.timeInLight,
    required this.timeInDeep,
    required this.timeInRem,
    required this.timeInStableBreath,
    required this.timeInUnstableBreath,
    required this.timeInSnoring,
    required this.timeInNoSnoring,
    required this.sleepEfficiency,
    required this.sleepRatio,
    required this.wakeRatio,
    required this.lightRatio,
    required this.deepRatio,
    required this.remRatio,
    required this.stableBreathRatio,
    required this.unstableBreathRatio,
    required this.snoringRatio,
    required this.noSnoringRatio,
    required this.breathingIndex,
    required this.breathingPattern,
    required this.wasoCount,
    required this.longestWaso,
    required this.sleepCycleCount,
    required this.sleepCycle,
    required this.sleepCycleTime,
    required this.unstableBreathCount,
    required this.snoringCount,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      sessionId: json['result']['session']['id'],
      state: json['result']['session']['state'],
      startTime: json['result']['session']['start_time'],
      endTime: json['result']['session']['end_time'],
      sleepStages: List<int>.from(json['result']['session']['sleep_stages']),
      breathStages: List<int>.from(json['result']['stat']['breath_stages']),
      snoringStages: List<int>.from(json['result']['stat']['snoring_stages']),
      sleepTime: DateTime.parse(json['result']['stat']['sleep_time']),
      wakeTime: DateTime.parse(json['result']['stat']['wake_time']),
      sleepIndex: json['result']['stat']['sleep_index'],
      sleepLatency: json['result']['stat']['sleep_latency'],
      wakeupLatency: json['result']['stat']['wakeup_latency'],
      lightLatency: json['result']['stat']['light_latency'],
      deepLatency: json['result']['stat']['deep_latency'],
      remLatency: json['result']['stat']['rem_latency'],
      timeInBed: json['result']['stat']['time_in_bed'],
      timeInSleepPeriod: json['result']['stat']['time_in_sleep_period'],
      timeInSleep: json['result']['stat']['time_in_sleep'],
      timeInWake: json['result']['stat']['time_in_wake'],
      timeInLight: json['result']['stat']['time_in_light'],
      timeInDeep: json['result']['stat']['time_in_deep'],
      timeInRem: json['result']['stat']['time_in_rem'],
      timeInStableBreath: json['result']['stat']['time_in_stable_breath'],
      timeInUnstableBreath: json['result']['stat']['time_in_unstable_breath'],
      timeInSnoring: json['result']['stat']['time_in_snoring'],
      timeInNoSnoring: json['result']['stat']['time_in_no_snoring'],
      sleepEfficiency: json['result']['stat']['sleep_efficiency'],
      sleepRatio: json['result']['stat']['sleep_ratio'],
      wakeRatio: json['result']['stat']['wake_ratio'],
      lightRatio: json['result']['stat']['light_ratio'],
      deepRatio: json['result']['stat']['deep_ratio'],
      remRatio: json['result']['stat']['rem_ratio'],
      stableBreathRatio: json['result']['stat']['stable_breath_ratio'],
      unstableBreathRatio: json['result']['stat']['unstable_breath_ratio'],
      snoringRatio: json['result']['stat']['snoring_ratio'],
      noSnoringRatio: json['result']['stat']['no_snoring_ratio'],
      breathingIndex: json['result']['stat']['breathing_index'],
      breathingPattern: json['result']['stat']['breathing_pattern'],
      wasoCount: json['result']['stat']['waso_count'],
      longestWaso: json['result']['stat']['longest_waso'],
      sleepCycleCount: json['result']['stat']['sleep_cycle_count'],
      sleepCycle: json['result']['stat']['sleep_cycle'],
      sleepCycleTime: List<String>.from(json['result']['stat']['sleep_cycle_time']),
      unstableBreathCount: json['result']['stat']['unstable_breath_count'],
      snoringCount: json['result']['stat']['snoring_count'],
    );
  }
}


Future<void> fetchData(String sessionId, String apiKey, String userId) async {
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
