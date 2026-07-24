package com.rengv.rg_gym

import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
   private val CHANNEL = "rg_gym/battery"

   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
      super.configureFlutterEngine(flutterEngine)

      MethodChannel(
         flutterEngine.dartExecutor.binaryMessenger,
         CHANNEL
      ).setMethodCallHandler { call, result ->
         when(call.method) {
            "isIgnoringBatteryOptimizations" -> {
               val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager

               val isIgnoring = powerManager.isIgnoringBatteryOptimizations(packageName)
               result.success(isIgnoring)
            }

            else -> {
               result.notImplemented()
            }
         }
      }
   }
}