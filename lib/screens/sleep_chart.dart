import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sleep Data Graph'),
        ),
        body: SleepDataWidget(),
      ),
    );
  }
}

class SleepDataWidget extends StatefulWidget {
  @override
  _SleepDataWidgetState createState() => _SleepDataWidgetState();
}

class _SleepDataWidgetState extends State<SleepDataWidget> {
  static const platform = MethodChannel('com.flutter_application_1.app/channel');
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _getReportData(); // 초기화 및 보고서 데이터 가져오기
  }

  Future<void> _getReportData() async {
    try {
      // MethodChannel을 통해 네이티브 코드에서 보고서 데이터 요청
      await platform.invokeMethod('getReportData');

      // 네이티브 코드에서 응답 처리
      platform.setMethodCallHandler((call) async {
        if (call.method == 'sendReportData') {
          setState(() {
            // 수신된 데이터를 Map으로 변환하여 상태 업데이트
            _reportData = Map<String, dynamic>.from(call.arguments);
          });
        }
      });
    } on PlatformException catch (e) {
      // MethodChannel 통신 중 발생한 오류 처리
      print("보고서 데이터를 가져오는 데 실패했습니다: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _reportData == null
        ? Center(child: CircularProgressIndicator()) // 데이터가 가져오는 동안 로딩 인디케이터 표시
        : SleepChart(reportData: _reportData!); // 데이터가 있으면 수면 차트 표시
  }
}

class SleepChart extends StatelessWidget {
  final Map<String, dynamic> reportData;

  SleepChart({required this.reportData});

  @override
  Widget build(BuildContext context) {
    // 보고서 데이터를 FlSpot 리스트로 변환하여 그래프에 사용
    List<FlSpot> startTimes = [];
    List<FlSpot> sleepTimes = [];
    List<FlSpot> wakeTimes = [];
    List<FlSpot> endTimes = [];

    // X축은 날짜를 나타내며, Y축은 절대 시간을 나타냅니다.
    // 예시 데이터에서 X축 값이 없는 경우 현재 날짜를 기준으로 설정
    final xValue = DateTime.now().millisecondsSinceEpoch.toDouble();

    startTimes.add(FlSpot(xValue, _parseDate(reportData['sessionStartTime'])));
    sleepTimes.add(FlSpot(xValue, _parseDate(reportData['sleepTime'])));
    wakeTimes.add(FlSpot(xValue, _parseDate(reportData['wakeTime'])));
    endTimes.add(FlSpot(xValue, _parseDate(reportData['sessionEndTime'])));

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: startTimes,
            isCurved: true,
            barWidth: 2,
            colors: [Colors.blue],
            belowBarData: BarAreaData(
              show: true,
              colors: [Colors.blue.withOpacity(0.3)],
            ),
          ),
          LineChartBarData(
            spots: sleepTimes,
            isCurved: true,
            barWidth: 2,
            colors: [Colors.green],
            belowBarData: BarAreaData(
              show: true,
              colors: [Colors.green.withOpacity(0.3)],
            ),
          ),
          LineChartBarData(
            spots: wakeTimes,
            isCurved: true,
            barWidth: 2,
            colors: [Colors.orange],
            belowBarData: BarAreaData(
              show: true,
              colors: [Colors.orange.withOpacity(0.3)],
            ),
          ),
          LineChartBarData(
            spots: endTimes,
            isCurved: true,
            barWidth: 2,
            colors: [Colors.red],
            belowBarData: BarAreaData(
              show: true,
              colors: [Colors.red.withOpacity(0.3)],
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return "${dateTime.hour}:${dateTime.minute}";
            },
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) {
              final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return "${dateTime.month}/${dateTime.day}";
            },
          ),
        ),
      ),
    );
  }

  double _parseDate(String dateStr) {
    final dateTime = DateTime.parse(dateStr);
    return dateTime.millisecondsSinceEpoch.toDouble();
  }
}
