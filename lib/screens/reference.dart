import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Reports List Example'),
        ),
        body: ReportsListWidget(),
      ),
    );
  }
}

class ReportsListWidget extends StatefulWidget {
  @override
  _ReportsListWidgetState createState() => _ReportsListWidgetState();
}

class _ReportsListWidgetState extends State<ReportsListWidget> {
  static const platform = MethodChannel('com.flutter_application_1.app/channel');
  List<ReportSet> _reportsList = [];

  @override
  void initState() {
    super.initState();
    _getReportsList();
  }

  Future<void> _getReportsList() async {
    List<dynamic> reportsData = [];
    try {
      reportsData = await platform.invokeMethod('GetMutipleReports');
    } on PlatformException catch (e) {
      print("Failed to get reports list: '${e.message}'.");
    } catch (e) {
      print("Failed to get reports list: '${e.toString()}'.");
    }

    setState(() {
      _reportsList = reportsData.map((data) => ReportSet.fromMap(data)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _reportsList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_reportsList[index].xUserId),
          subtitle: Text(_reportsList[index].timezone),
        );
      },
    );
  }
}

class ReportSet {
  final String xUserId;
  final String timezone;
  final String? sessionId;
  final String startTime;
  final String? endTime;
  final String? unexpectedEndTime;
  final String createdTimezone;
  final String? sleepTime;
  final String? wakeTime;

  ReportSet({
    required this.xUserId,
    required this.timezone,
    this.sessionId,
    required this.startTime,
    this.endTime,
    this.unexpectedEndTime,
    required this.createdTimezone,
    this.sleepTime,
    this.wakeTime,
  });

  factory ReportSet.fromMap(Map<String, dynamic> map) {
    return ReportSet(
      xUserId: map['x_user_id'],
      timezone: map['timezone'],
      sessionId: map['session_id'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      unexpectedEndTime: map['unexpected_end_time'],
      createdTimezone: map['created_timezone'],
      sleepTime: map['sleep_time'],
      wakeTime: map['wake_time'],
    );
  }
}
