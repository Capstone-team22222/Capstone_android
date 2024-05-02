package com.example.flutter_application_1

import androidx.lifecycle.MutableLiveData

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import ai.asleep.asleepsdk.Asleep
import ai.asleep.asleepsdk.tracking.SleepTrackingManager
import ai.asleep.asleepsdk.AsleepErrorCode
import ai.asleep.asleepsdk.data.AsleepConfig
import ai.asleep.asleepsdk.tracking.Reports
import ai.asleep.asleepsdk.data.Report



class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.flutter_application_1.app/channel"
    var sleepTrackingManager:  SleepTrackingManager? = null
    var asleepConfig: AsleepConfig? = null
    var sessionIdLiveData =  MutableLiveData ("") //세션 id 저장 어케함


    private fun createSleepTrackingManager(){
        sleepTrackingManager = Asleep.createSleepTrackingManager(asleepConfig, object : SleepTrackingManager.TrackingListener {
            override fun onCreate() {
                //Log.d(">>>>> sleepTrackingManager - ", "onCreate: start tracking")
                //Log.d(">>>>> RecordService", "onCreate) TrackingStatus.sessionId: ${viewModel.sleepTrackingManager?.getTrackingStatus()?.sessionId}")
                //Toast.makeText(applicationContext, "Create Session: ${viewModel.sleepTrackingManager?.getTrackingStatus()?.sessionId}", Toast.LENGTH_SHORT).show()
            }

            override fun onUpload(sequence: Int) {
                //Log.d(">>>>> sleepTrackingManager - ", "onUpload: $sequence")
                //viewModel.setSequence(sequence) viewmodel 리팩터링
            }

            override fun onClose(sessionId: String) {
                //Log.d(">>>>> sleepTrackingManager - ", "onClose: $sessionId")
                //Log.d(">>>>> RecordService", "onClose) TrackingStatus.sessionId: ${viewModel.sleepTrackingManager?.getTrackingStatus()?.sessionId}")
                sessionIdLiveData.postValue(sessionId)
                //Toast.makeText(applicationContext, "Close: ${viewModel.sleepTrackingManager?.getTrackingStatus()?.sessionId}", Toast.LENGTH_SHORT).show()
            }

            override fun onFail(errorCode: Int, detail: String) {
                //Log.d(">>>>> sleepTrackingManager - ", "onFail: $errorCode - $detail")
                //viewModel.setErrorData(errorCode, detail)
            }
        })
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "createAsleepInstance" -> {
                    Asleep.initAsleepConfig(
                        context = applicationContext,
                        apiKey = "sHDt5WgLsRgU0knI7KnCX7qnAPWzhundB8VMYqgF",
                        userId = null,
                        baseUrl = null,
                        callbackUrl = null,
                        service = "[input your AppName]",
                        object : Asleep.AsleepConfigListener {
                            override fun onSuccess(userId: String?, asleepConfig: AsleepConfig?) {

                                /* save userId and asleepConfig */

                            }
                            override fun onFail(errorCode: Int, detail: String) {

                            }
                        })

                }

                "StartSleepTracking" -> {
                    sleepTrackingManager?.let { manager ->
                        manager.startSleepTracking()
                        println("측정 시작1")
                    } ?: run {
                        // sleepTrackingManager가 null일 때 실행할 코드
                        println("매니저 없음")
                        createSleepTrackingManager()
                        sleepTrackingManager?.startSleepTracking()
                        println("측정 시작2")
                    }
                }

                "StopSleepTracking" -> {
                    sleepTrackingManager?.stopSleepTracking()
                    println("측정 종료")
                }

                "ShowReport" -> {
                    val reports = Asleep.createReports(asleepConfig)

                    reports?.getReport(sessionIdLiveData.value!!, object : Reports.ReportListener {
                        override fun onSuccess(report: Report?) {
                            //Log.d(">>>>> getReport", "onSuccess: $report")
                            //_reportLiveData.postValue(report)
                            println("결과 가져옴")

                        }

                        override fun onFail(errorCode: Int, detail: String) {
                            //Log.d(">>>>> getReport", "onFail: $errorCode - $detail")
                            //_errorDetail = detail
                            //_errorCodeLiveData.postValue(errorCode)
                            println("결과 못가져옴")

                        }
                    })
                    }

                "ShowCurrent" -> {

                }
                else -> result.notImplemented() //호출한 함수가 없을 때
            }
        }
    }


}
