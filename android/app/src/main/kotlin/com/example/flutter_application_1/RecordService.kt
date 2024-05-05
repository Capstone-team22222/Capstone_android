package com.example.flutter_application_1

import ai.asleep.asleepsdk.Asleep
import ai.asleep.asleepsdk.tracking.SleepTrackingManager
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

//여기에 메소드 구현하고 mainactivity에서 호출
//MVVM패턴 사용 ㄴ
class RecordService : Service() {

    override fun onCreate() { //서비스가 생성될 때 한번만 실행됨
        super.onCreate()
        createNotification()
        startForegroundService()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createNotification()
        startForeground(1, notification)

        return START_NOT_STICKY //서비스를 명시적으로 다시 시작할 때 까지 만들지 않음
    }

    private fun createNotification(): Notification {
        val notificationChannelId = "MY_CHANNEL_ID"

        // Android O 이상에서는 알림 채널을 생성해야 함
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                notificationChannelId,
                "My Foreground Service",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        val notificationBuilder = NotificationCompat.Builder(this, notificationChannelId)
        return notificationBuilder.setOngoing(true)
            .setContentTitle("서비스 실행 중")
            .setContentText("이 서비스는 포그라운드에서 실행 중입니다.")
            .setPriority(NotificationManager.IMPORTANCE_MIN)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }

    override fun onBind(intent: Intent): IBinder? {
        // 바인딩을 제공하지 않는 서비스의 경우 null 반환
        return null
    }

    private fun startForegroundService(){

    }

//    val serviceIntent = Intent(this, RecordService::class.java)
//    startForegroundService(serviceIntent)

}