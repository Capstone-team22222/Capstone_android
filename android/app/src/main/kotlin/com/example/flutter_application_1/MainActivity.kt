package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import ai.asleep.asleepsdk.Asleep
import ai.asleep.asleepsdk.data.AsleepConfig
import ai.asleep.asleepsdk.AsleepErrorCode


class MainActivity: FlutterActivity(){
    private val CHANNEL = "com.example.myapp/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "createInstance" -> {
                    Asleep.initAsleepConfig(
                        context = applicationContext,
                        apiKey = "api key",
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
                else -> result.notImplemented()
            }
        }
    }


}
