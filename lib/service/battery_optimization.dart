import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

class BatteryOptimization {
  static const MethodChannel _channel = MethodChannel('rg_gym/battery');

  static Future<bool> isDisabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');

      return result ?? false;
    } catch(e) {
      return false;
    }
  }

  static Future<void> openSettings() async {
    const packageName = "com.rengv.rg_gym";

    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
      data: 'package:$packageName'
    );

    await intent.launch();
  }
}