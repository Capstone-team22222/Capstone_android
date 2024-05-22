import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: SleepGraph(key: null),
  ));
}

class SleepGraph extends StatefulWidget {
  const SleepGraph({super.key});
  @override
  _SleepGraphState createState() => _SleepGraphState();
}

class _SleepGraphState extends State<SleepGraph> {
  List<SleepData> sleepDataList = [];
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context; // BuildContext 저장
    fetchData("yourSessionId", "yourApiKey", "yourUserId");
  }

  // 데이터 가져오기 함수
  Future<void> fetchData(String sessionId, String apiKey, String userId) async {
    final String apiUrl = "https://api.asleep.ai/data/v3/sessions/$sessionId";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "x-api-key": apiKey,
          "x-user-id": userId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          sleepDataList = [SleepData.fromJson(jsonResponse)];
        });
      } else {
        _showErrorSnackBar("Failed to fetch data: ${response.statusCode}");
      }
    } catch (error) {
      _showErrorSnackBar("Failed to fetch data: $error");
    }
  }

  // 에러 메시지 표시 함수
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Graph'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 300,
          child: _buildChart(), // 차트 빌드
        ),
      ),
    );
  }

  // 차트 빌드 함수
  Widget _buildChart() {
    List<charts.Series<TimeSeriesData, DateTime>> seriesList = [];

    if (sleepDataList.isNotEmpty) {
      for (var sleepData in sleepDataList) {
        seriesList.add(charts.Series<TimeSeriesData, DateTime>(
          id: 'Sleep Data ${sleepData.sessionStartTime.day}',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TimeSeriesData data, _) => data.time,
          measureFn: (TimeSeriesData data, _) => data.value,
          data: [
            TimeSeriesData(sleepData.sessionStartTime, _timeToDouble(sleepData.sessionStartTime)),
            TimeSeriesData(sleepData.sleepTime, _timeToDouble(sleepData.sleepTime)),
            TimeSeriesData(sleepData.wakeTime, _timeToDouble(sleepData.wakeTime)),
            TimeSeriesData(sleepData.sessionEndTime, _timeToDouble(sleepData.sessionEndTime)),
          ],
        ));
      }
    }

    return charts.TimeSeriesChart(
      seriesList,
      animate: true,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      defaultRenderer: charts.LineRendererConfig(includePoints: true),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
        viewport: charts.NumericExtents(0, 24),
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec((num? value) {
          if (value == null) return '';
          final int hour = value.toInt();
          return '$hour:00';
        }),
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'MM-dd',
            transitionFormat: 'MM-dd',
          ),
        ),
      ),
    );
  }

  // 시간을 double 형식으로 변환
  double _timeToDouble(DateTime time) {
    return time.hour + time.minute / 60.0;
  }
}

class SleepData {
  final DateTime sessionStartTime;
  final DateTime sleepTime;
  final DateTime wakeTime;
  final DateTime sessionEndTime;

  SleepData({
    required this.sessionStartTime,
    required this.sleepTime,
    required this.wakeTime,
    required this.sessionEndTime,
  });

  // JSON 데이터를 SleepData 객체로 변환
  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      sessionStartTime: DateTime.parse(json['result']['session']['start_time']),
      sleepTime: DateTime.parse(json['result']['stat']['sleep_time']),
      wakeTime: DateTime.parse(json['result']['stat']['wake_time']),
      sessionEndTime: DateTime.parse(json['result']['session']['end_time']),
    );
  }
}

class TimeSeriesData {
  final DateTime time;
  final double value;

  TimeSeriesData(this.time, this.value);
}
