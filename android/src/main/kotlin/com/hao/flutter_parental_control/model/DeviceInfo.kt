package com.hao.flutter_parental_control.model

import android.content.Context
import android.media.AudioManager
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import com.hao.flutter_parental_control.utils.AppConstants

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
                AppConstants.SYSTEM_NAME to AppConstants.ANDROID,
                AppConstants.DEVICE_NAME to Build.MODEL,
                AppConstants.DEVICE_MANUFACTURER to Build.MANUFACTURER,
                AppConstants.DEVICE_VERSION to Build.VERSION.RELEASE,
                AppConstants.DEVICE_API_LEVEL to Build.VERSION.SDK_INT,
                AppConstants.DEVICE_BOARD to Build.BOARD,
                AppConstants.DEVICE_HARDWARE to Build.HARDWARE,
                AppConstants.DEVICE_DISPLAY to Build.DISPLAY,
                AppConstants.BATTERY_LEVEL to "$batteryLevel%",
                AppConstants.SCREEN_BRIGHTNESS to screenBrightness.toString(),
                AppConstants.VOLUME to volume.toString(),
                AppConstants.DEVICE_ID to Settings.Secure.getString(
                    context.contentResolver,
                    Settings.Secure.ANDROID_ID
                )
            )
        }
    }
}
