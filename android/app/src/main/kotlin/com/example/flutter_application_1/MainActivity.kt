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
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import java.time.LocalTime
import kotlin.concurrent.thread
import kotlin.properties.Delegates

/*

> project를 실행하고 기상 시간을 입력하고 기다림. 자동으로 수면 분석 후 알람 울림.

성공 :
 > 지정된 시간에 측정을 시작할 수 있음.
 > 기상 시간 기준 20분 전부터 sleepLevel을 측정함.
 > 얕은 수면(1)이 3번 측정되면 알람을 울림.
 > 사용자에게 기상 시간을 입력 받아 사용하는 기능.
 > 알람이 울릴 때 알람화면 안뜨는 것을 수정함.
 > 알람 문제 소리 문제 해결함.


 */


@AndroidEntryPoint
class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.flutter_application_1.app/channel"
    private var asleepConfig: AsleepConfig? = null
    private var userId: String? = null
    private val MY_PERMISSIONS_REQUEST_RECORD_AUDIO = 1
    private val executor: ScheduledExecutorService = Executors.newScheduledThreadPool(4)

    private lateinit var viewModel: MainViewModel

    var flag: Boolean by Delegates.observable(false) { prop, old, new ->
        println("flag값이 변경됨")
    }

    //사용자가 일어나야 하는 시간을 설정(24Hour), ex) 8,0 => 8시에 기상
    var wakeupHour:Int =8
    var wakeupMin:Int =0

    //StartSleepTracking 자동으로 실행될 시간 설정(24Hour), ex) 11, 0 => 매일 11시 부터 sleep 측정
    val startTrackingHour:Int = 23
    val startTrackingMin:Int = 0

    //기상 시간 기준, 측정을 시작할 시간을 설정, ex) 20 => wakeupHour = 7, wakeupMin = 40
    val repeatTime:Long = 20

    // repeatReport를 몇초 주기로 검사할지(단위 : sec), ex) 30초 주기로 데이터를 검사하겠다.
    val loopTime:Long = 30

    private var nativeChannel: MethodChannel? = null // android에서 flutter용 MethodChannel





    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel = ViewModelProvider(this).get(MainViewModel::class.java)



    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)
        var date : String
        nativeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "myChannel")



        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
               "createAsleepInstance" ->  { //자동 실행됨
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                        // 권한이 아직 부여되지 않았다면, 권한 요청
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), MY_PERMISSIONS_REQUEST_RECORD_AUDIO)
                    } else {
                        // 권한이 이미 부여되었다면, 마이크 사용 가능
                    }

                    Asleep.DeveloperMode.isOn = true
                    Asleep.initAsleepConfig(
                        context = applicationContext,
                        apiKey = "3vocIdIG1j7CBtr2hehvmKfzrrm1p40dtfuocF3t",
                        userId = null,
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

                   stopTracking() //넣어야 측정됨;;

//
//                    println("(기상 시간 - repeatTime)을 구함, sleep stage level를 처음 얻어오는 시간을 알아냄 ")
//                    val (newHour, newMin) = findHourAndMin(wakeupHour, wakeupMin, repeatTime) //일어날 시간의 20분 전의 시간을 구함
//                    wakeupHour = newHour
//                    wakeupMin = newMin
//
//                   println("$wakeupHour:$wakeupMin") // 계산된 시간
//
//
//                    startTrackingManager() // 지정해놓은 시간에 측정이 시작됨
//                    wakeup20()
//
//                   thread {
//                       while (!flag) {
//                           println("Waiting for flag to become true...")
//                           Thread.sleep(10000) // Sleep for 1 second
//                       }
//                       println("Alarm 호출")
//                       runOnUiThread {
//                           nativeChannel?.invokeMethod("ring", "ok")
//                       }
//                   }
//
//                   result.success("Asleep instance created")

                }


                "StartSleepTracking" -> {
//                    viewModel.setStartTrackingTime()
//                    viewModel.setErrorData(null, null)
//                    viewModel.setReport(null)
//                    startService(Intent(this, RecordService::class.java).apply {
//                        action = RecordService.ACTION_START_OR_RESUME_SERVICE
//                    })
                }

                "StopSleepTracking" -> {
//                    startService(Intent(this, RecordService::class.java).apply {
//                        action = RecordService.ACTION_STOP_SERVICE
//                    })
                }

                "GetReport" -> {
//                    viewModel.getReport()
//                    viewModel.reportLiveData.observe(this) { report ->
//                        if (report != null) {
//                            println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//                            println(report.toString())
//                            println(report.stat.toString())
//                        } else {
//                            println("Report is null")
//                        }
//                    }
                }

                "ShowCurrent" -> {
                    ringAlarm()

                }

                "Wakeup" -> {
                    wakeupHour = Integer.parseInt(call.argument<String>("hour"))
                    wakeupMin = Integer.parseInt(call.argument<String>("min"))

                    println(">>>>>> 받아온 시간 : $wakeupHour : $wakeupMin")

//                    stopTracking() //넣어야 측정됨;;

                    println("(기상 시간 - repeatTime)을 구함, sleep stage level를 처음 얻어오는 시간을 알아냄 ")

                    val (newHour, newMin) = findHourAndMin(wakeupHour, wakeupMin, repeatTime) //일어날 시간의 20분 전의 시간을 구함
                    wakeupHour = newHour
                    wakeupMin = newMin

                    println("$wakeupHour:$wakeupMin") // 계산된 시간



                    startTrackingManager() // 지정해놓은 시간에 측정이 시작됨
                    wakeup20()

                    thread {
                        while (!flag) {
                            println("Waiting for flag to become true...")
                            Thread.sleep(10000) // Sleep for 1 second
                        }
                        println("Alarm 호출")
                        runOnUiThread {
                            nativeChannel?.invokeMethod("ring", "ok")
                        }
                    }

                    result.success("Asleep instance created")





                }

                else -> result.notImplemented() //호출한 함수가 없을 때
            }
        }


    }


    fun stopTracking(){
        startService(Intent(this, RecordService::class.java).apply {
            action = RecordService.ACTION_STOP_SERVICE
        })
    }

    // 매일 밤 11시 마다 sleeptracking 자동 실행
    fun startTrackingManager(){
        println("startTrackingManager Start")
        val now = LocalDateTime.now() //현재 시간을 가져와서 지정한 시간까지의 시간을 차를 구함.
        val targetTime = now.withHour(startTrackingHour).withMinute(startTrackingMin).withSecond(0).withNano(0) //자동으로 실행할 시간

        val initialDelay = if (now.isBefore(targetTime)) {
            ChronoUnit.MILLIS.between(now, targetTime)
        } else {
            ChronoUnit.MILLIS.between(now, targetTime.plusDays(1))
        }

        val period = TimeUnit.DAYS.toMillis(1)

        val task2 = Runnable { //원하는 시간에 Tracking Manager가 실행됨.

            println("정해진 시간에 Tracking 시작 실행됨.")
            viewModel.setStartTrackingTime()
            viewModel.setErrorData(null, null)
            viewModel.setReport(null)
            startService(Intent(this, RecordService::class.java).apply {
                action = RecordService.ACTION_START_OR_RESUME_SERVICE
            })



        }

        //원하는 시간에 시작하도록 해주는 스케줄러
        executor.scheduleAtFixedRate(task2, initialDelay, period, TimeUnit.MILLISECONDS)




    }

    fun ringAlarm() {
        //native에서 알람 호출
        println("ringAlarm 실행")
        nativeChannel?.invokeMethod("ring","ok")

    }

    // 30초(loopTime) 마다 sleepLevel를 받음, level 1이 3번 이상이면 알람을 울림.
    fun repeatReport(){
        println("30초(loopTime)마다 SleepLevel 검사")

        var counter:Int = 0 // counter가 3이면 얕은 수면이라고 판단

        var task1 = Runnable { //수면 검사 : 30초에 한번씩 검사
            viewModel.getcurrentanalysis() //실시간으로 받아옴
            println(">>>>>>>>>수면 상태 : " + viewModel._sleepLevel) //sleepStage 리스트의 마지막 요소
            if(viewModel._sleepLevel == 1){// level 1이 3번 나오면 얕은 수면 중이라 판단.
                counter++
                println(">>>>>>>>>수면 상태 : " + viewModel._sleepLevel + "카운터 : "+ counter)
                if(counter == 3){ //카운터 얕은수면(1) 3번 나오면 종료
                    println(">>>>>>>>>>>>카운터 종료")
                    stopTracking()
                    flag = true //알람을 울리기 위한 boolean flag => true : 알람 실행
                    println(">>>>>>>>>>>>측정 종료")
                }else{
                    println(">>>>>>>>>>>>>수면 중")
                }
            }

        }
        executor.scheduleAtFixedRate(task1, 0, loopTime, TimeUnit.SECONDS)//30초(loopTime) 마다
    }


    fun wakeup20(){ // 기상 시간 20분 전에 실행 설정
        println("20분 전 시간 설정")
        val current_Time = LocalDateTime.now() //현재 시간으로 부터 목표시간을 구해 원하는 시간에 설정
        val target_Time = current_Time.withHour(wakeupHour).withMinute(wakeupMin).withSecond(0).withNano(0) //자동으로 실행할 시간


        val initial_Delay = if (current_Time.isBefore(target_Time)) {
            ChronoUnit.MILLIS.between(current_Time, target_Time)
        } else {
            ChronoUnit.MILLIS.between(current_Time, target_Time.plusDays(1))
        }

        val period = TimeUnit.DAYS.toMillis(1)


        val task3 = Runnable{ //wakeup Hour, Min부터 측정을 시작함
           stopTracking()//이게 있어야 측정가능
            println("Sleep Level 측정 시작")
            repeatReport()
        }

        executor.scheduleAtFixedRate(task3, initial_Delay, period, TimeUnit.MILLISECONDS) //스케줄러 설정

    }






}
