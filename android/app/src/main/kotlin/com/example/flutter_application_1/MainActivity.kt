package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterFragmentActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.ContextCompat
import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.lifecycle.ViewModelProvider
import android.content.Intent


import ai.asleep.asleepsdk.Asleep
import ai.asleep.asleepsdk.data.AsleepConfig
import ai.asleep.asleepsdk.data.Report
import ai.asleep.asleepsdk.data.SleepSession
import android.util.Log
import androidx.core.app.ActivityCompat
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.flutter_application_1.app/channel"
    private var asleepConfig: AsleepConfig? = null
    private var userId: String? = null
    private val MY_PERMISSIONS_REQUEST_RECORD_AUDIO = 1
    private lateinit var viewModel: MainViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProvider(this).get(MainViewModel::class.java)
    }

    fun initasleepconfig(){
        Asleep.DeveloperMode.isOn = true

        Asleep.initAsleepConfig(
            context = applicationContext,
            apiKey = "sHDt5WgLsRgU0knI7KnCX7qnAPWzhundB8VMYqgF",
            userId = viewModel.userId,
            baseUrl = null,
            callbackUrl = null,
            service = "[input your AppName]",
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
    class reportset(
        x_user_id: String?,
        timezone: String,
        session_id: String?,
        start_time: String,
        end_time: String?,
        unexpected_end_time: String?,
        created_timezone: String,
        sleep_time: String?,
        wake_time: String?){

        var x_user_id: String? = x_user_id
        var timezone: String = timezone
        var session_id: String? = session_id
        var start_time: String = start_time
        var end_time: String? = end_time
        var unexpected_end_time: String? = unexpected_end_time
        var created_timezone: String = created_timezone
        var sleep_time: String? = sleep_time
        var wake_time: String? = wake_time

        fun toMap(): Map<String, Any?> {
            return mapOf(
                "x_user_id" to x_user_id,
                "timezone" to timezone,
                "session_id" to session_id,
                "start_time" to start_time,
                "end_time" to end_time,
                "unexpected_end_time" to unexpected_end_time,
                "created_timezone" to created_timezone,
                "sleep_time" to sleep_time,
                "wake_time" to wake_time
            )
        }

    }

    fun MutableList<reportset>.toMapList(): List<Map<String, Any?>> {
        return this.map { it.toMap() }
    }


    fun getreport(multiplereports: List<SleepSession>?): MutableList<reportset> {
        val reportsmap: MutableList<reportset> = mutableListOf()
        var report: Report?
        if (multiplereports != null){
            for(obj in multiplereports) {
                viewModel.getReport(obj.sessionId)
                report = viewModel.reportLiveData.value
                report?.let {
                    reportsmap.add(reportset(
                        x_user_id = viewModel.userId,
                        timezone = it.timezone,
                        session_id = obj.sessionId,
                        start_time = it.session?.startTime ?: "",
                        end_time = it.session?.endTime ?: "",
                        unexpected_end_time = it.session?.unexpectedEndTime ?: "",
                        created_timezone = it.session?.createdTimezone ?: "",
                        sleep_time = it.stat?.sleepTime ?: "",
                        wake_time = it.stat?.wakeTime ?: ""
                    ))
                }
            }
            return reportsmap
        }
        return reportsmap
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

                    initasleepconfig()
                }

                "StartSleepTracking" -> {
                    viewModel.setStartTrackingTime()
                    viewModel.setErrorData(null,null)
                    viewModel.setReport(null)
                    if(viewModel.userId!=null){
                        startService(Intent(this, RecordService::class.java).apply {
                        action = RecordService.ACTION_START_OR_RESUME_SERVICE
                    })
                    } else {
                        initasleepconfig()
                        startService(Intent(this, RecordService::class.java).apply {
                            action = RecordService.ACTION_START_OR_RESUME_SERVICE
                    })
                    }
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
                            println(report)
                        } else {
                            println("Report is null")
                        }
                    }
                }

                "GetMutipleReports" -> {
                    viewModel.getMultipleReports("2024-05-24")
                    val reportsList = getreport(viewModel.MultipleReportsLiveData.value)
                    val reportsData = reportsList.toMapList()
                    result.success(reportsData)
                }

                "ShowCurrent" -> {
                    viewModel.getCurrentAnalysis()
                }
                else -> result.notImplemented() //호출한 함수가 없을 때
            }
        }
    }


}
