package com.hao.flutter_parental_control.model

import android.content.Context
import android.media.AudioManager
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings

data class DeviceInfo(
    val systemName: String,
    val deviceName: String,
    val deviceManufacturer: String,
    val deviceVersion: String,
    val deviceApiLevel: Int,
    val deviceBoard: String,
    val deviceHardware: String,
    val deviceDisplay: String,
    val batteryLevel: String,
    val screenBrightness: String,
    val volume: String,
    val deviceId: String
) {
    companion object {
        // Method to create a map of device info from the context
        fun getDeviceInfo(context: Context): Map<String, Any> {
            val batteryManager =
                context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val batteryLevel =
                batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)

            val screenBrightness =
                Settings.System.getInt(
                    context.contentResolver,
                    Settings.System.SCREEN_BRIGHTNESS,
                    0
                )

            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val volume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)

            return mapOf(
                "systemName" to "Android",
                "deviceName" to Build.MODEL,
                "deviceManufacturer" to Build.MANUFACTURER,
                "deviceVersion" to Build.VERSION.RELEASE,
                "deviceApiLevel" to Build.VERSION.SDK_INT,
                "deviceBoard" to Build.BOARD,
                "deviceHardware" to Build.HARDWARE,
                "deviceDisplay" to Build.DISPLAY,
                "batteryLevel" to "$batteryLevel%",
                "screenBrightness" to screenBrightness.toString(),
                "volume" to volume.toString(),
                "deviceId" to Settings.Secure.getString(
                    context.contentResolver,
                    Settings.Secure.ANDROID_ID
                )
            )
        }
    }
}
