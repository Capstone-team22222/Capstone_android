package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import ai.asleep.asleepsdk.Asleep
import ai.asleep.asleepsdk.data.AsleepConfig
import ai.asleep.asleepsdk.AsleepErrorCode
import androidx.core.app.ActivityCompat
import android.Manifest
import android.util.Log
import androidx.lifecycle.MutableLiveData
import ai.asleep.asleepsdk.tracking.SleepTrackingManager
import ai.asleep.asleepsdk.data.Report
import ai.asleep.asleepsdk.tracking.Reports

import android.os.Handler // 3분 대기를 위한 import
import android.os.Looper


/*
viewModel을 이용해서 적용시키기 어렵다고 생각해서 필요한 요소를 골라가며 적용 중
메소드 설정 필요
 */

class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.example.myapp/native"
    public var _asleepConfig = MutableLiveData<AsleepConfig?>()
    public var _userId : String? = null
    public var _sessionId : String? = null







    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "createInstance" -> {
                    Log.d("kotlin sleep","성공1")

                    Asleep.DeveloperMode.isOn = true //개발자 모드 설정, 일반 모드는 생략


                    Asleep.initAsleepConfig(
                        context = applicationContext,
                        apiKey = "3vocIdIG1j7CBtr2hehvmKfzrrm1p40dtfuocF3t",
                        userId = null,
                        baseUrl = null,
                        callbackUrl = null,
                        service = "Capstone_android",
                        object : Asleep.AsleepConfigListener {
                            override fun onSuccess(userId: String?, asleepConfig: AsleepConfig?) {
                                _asleepConfig.value = asleepConfig
                                _userId = userId

                                /* save userId and asleepConfig */
                                Log.d(">>>> AsleepConfigListener", "onSuccess: userId - $userId")

                            }
                            override fun onFail(errorCode: Int, detail: String) {
                                Log.d(">>>> AsleepConfigListener", "onFail: $errorCode - $detail")

                            }
                        }) //설정 끝

                    //시작
                    // 마이크 녹음 기능
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 0)
                    Log.d("kotlin sleep","성공2, 마이크 O")


                    //슬립 매니저 설정
                    var sleepTrackingManager = Asleep.createSleepTrackingManager(asleepConfig = _asleepConfig.value, object : SleepTrackingManager.TrackingListener {
                        override fun onCreate() {
                            Log.d(">>>> AsleepConfigListener", "onSuccess: 성공n")

                        }

                        override fun onUpload(sequence: Int) {
                        }

                        override fun onClose(sessionId: String) {

                            _sessionId = sessionId //종료 시 sessionId 받음
                            Log.d(">>>> AsleepConfigListener", "트랙킹 매니저 닫힘")
                        }

                        override fun onFail(errorCode: Int, detail: String) {
                            Log.d(">>>> AsleepConfigListener", "onFail: 실패 슬립트랙킹매니저")
                        }
                    })



                    //측정시작
                    sleepTrackingManager?.startSleepTracking()
                    Log.d("kotlin sleep","성공3, 측정 중")

                    //개발자 모드 측정 2분 ... 3분 대기후 종료 테스트
                    Handler(Looper.getMainLooper()).postDelayed({
                        //측정 종료
                        sleepTrackingManager?.stopSleepTracking()
                        Log.d("kotlin sleep","성공4, 3분 끝 종료")
                    }, 3000)





                    //reports 설정
                    var reports = Asleep.createReports(asleepConfig = _asleepConfig.value)

                    //데이터 가져오기
                    reports?.getReport(sessionId =_sessionId!!, object : Reports.ReportListener {
                        override fun onSuccess(report: Report?) {
                            Log.d(">>>>> getReport", "onSuccess: $report")


                        }

                        override fun onFail(errorCode: Int, detail: String) {
                            Log.d(">>>>> getReport", "onFail: $errorCode - $detail")
                        }
                    })






                }
                else -> result.notImplemented()
            }
        }
    }








}
