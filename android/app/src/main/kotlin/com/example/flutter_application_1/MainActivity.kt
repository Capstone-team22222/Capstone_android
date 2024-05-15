package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.ContextCompat
import android.Manifest
import android.content.pm.PackageManager
import android.app.Activity
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.activity.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import android.content.Intent

import com.example.flutter_application_1.MainViewModel

import ai.asleep.asleepsdk.Asleep
import ai.asleep.asleepsdk.tracking.SleepTrackingManager
import ai.asleep.asleepsdk.data.AsleepConfig
import ai.asleep.asleepsdk.tracking.Reports
import ai.asleep.asleepsdk.data.Report
import android.util.Log
import androidx.core.app.ActivityCompat
import dagger.hilt.android.AndroidEntryPoint

//kotlin오류 시 gradle 재로딩
//함수는 거의 viewmodel에 구현  mainactivity에서 viewmodel에 있는 함수 호출

@AndroidEntryPoint
class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.flutter_application_1.app/channel"
    private var asleepConfig: AsleepConfig? = null
    private var userId: String? = null
    private val MY_PERMISSIONS_REQUEST_RECORD_AUDIO = 1


class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.example.myapp/native"
    public var _asleepConfig = MutableLiveData<AsleepConfig?>()
    public var _userId : String? = null
    public var _sessionId : String? = null





    private lateinit var viewModel: MainViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProvider(this).get(MainViewModel::class.java)


    }



    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "createAsleepInstance" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                        // 권한이 아직 부여되지 않았다면, 권한 요청
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), MY_PERMISSIONS_REQUEST_RECORD_AUDIO)
                    } else {
                        // 권한이 이미 부여되었다면, 마이크 사용 가능
                    }

                    Asleep.DeveloperMode.isOn = true
                    Asleep.initAsleepConfig(
                        context = applicationContext,
                        apiKey = "sHDt5WgLsRgU0knI7KnCX7qnAPWzhundB8VMYqgF",
                        userId = null,
                        baseUrl = null,
                        callbackUrl = null,
                        service = "Capstone_android",
                        object : Asleep.AsleepConfigListener {
                            override fun onSuccess(userId: String?, asleepConfig: AsleepConfig?) {
                                viewModel.setUserId(userId)
                                viewModel.setAsleepConfig(asleepConfig)
                                println(viewModel.toString())
                                Log.d(">>>> AsleepConfigListener", "onSuccess: userId - $userId")
                                Log.d(">>>> AsleepConfigListener", "onSuccess: Developer Id - $userId")

                            }
                            override fun onFail(errorCode: Int, detail: String) {
                                Log.d(">>>> AsleepConfigListener", "onFail: $errorCode - $detail")

                            }
                        })

                }

                "StartSleepTracking" -> {
                    viewModel.setStartTrackingTime()
                    viewModel.setErrorData(null,null)
                    viewModel.setReport(null)
                    startService(Intent(this, RecordService::class.java).apply {
                        action = RecordService.ACTION_START_OR_RESUME_SERVICE
                    })
                }

                "StopSleepTracking" -> {
                    startService(Intent(this, RecordService::class.java).apply {
                        action = RecordService.ACTION_STOP_SERVICE
                    })
                }

                "GetReport" -> {
                    viewModel.getReport()
                    viewModel.reportLiveData.observe(this) { report ->
                        if (report != null) {
                            println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
                            println(report.toString())
                            println(report.stat.toString())
                        } else {
                            println("Report is null")
                        }
                    }
                }

                "ShowCurrent" -> {
                    viewModel.getcurrentanalysis()
                    println(viewModel.SessionLiveData.toString())
                }
                else -> result.notImplemented() //호출한 함수가 없을 때
            }
        }
    }








}
