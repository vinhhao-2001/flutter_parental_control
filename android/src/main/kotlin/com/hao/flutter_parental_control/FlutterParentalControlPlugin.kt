package com.hao.flutter_parental_control

import android.content.Context
import android.content.Intent

import androidx.annotation.NonNull
import com.hao.flutter_parental_control.model.AppUsageInfo
import com.hao.flutter_parental_control.model.DeviceInfo
import com.hao.flutter_parental_control.service.InstallAppService
import com.hao.flutter_parental_control.utils.AppConstants
import com.hao.flutter_parental_control.utils.RequestPermissions

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

import org.json.JSONObject

/** FlutterParentalControlPlugin */
class FlutterParentalControlPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var context: Context

        companion object{
            var eventSink: EventChannel.EventSink? = null
        }
    // Hàm khởi tạo
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, AppConstants.METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        val eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, AppConstants.EVENT_CHANNEL)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }

        })

    }

    // Hàm
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)

        eventSink = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {

            AppConstants.GET_DEVICE_INFO -> {
                getDeviceInfo(result)
            }

            AppConstants.START_SERVICE -> {
                RequestPermissions(context).requestUsageStatsPermissions()
                val serviceIntent = Intent(context, InstallAppService::class.java)
                    context.startService(serviceIntent)
            }

            AppConstants.BLOCK_APP_METHOD -> {
                val blockApps = call.argument<List<String>>("blockApps") ?: emptyList<String>()
                val intent = Intent(AppConstants.BROADCAST_ACCESSIBILITY)
                intent.putStringArrayListExtra("blockApps", ArrayList(blockApps))
                context.sendBroadcast(intent)
                result.success("")
            }

            AppConstants.BLOCK_WEBSITE_METHOD -> {
                val blockWebsites =
                    call.argument<List<String>>("blockWebsites") ?: emptyList<String>()

                val intent = Intent(AppConstants.BROADCAST_ACCESSIBILITY)
                intent.putStringArrayListExtra("blockWebsites", ArrayList(blockWebsites))
                context.sendBroadcast(intent)
                result.success("")
            }

            AppConstants.GET_APP_USAGE_INFO -> {
                val appUsageInfoList = AppUsageInfo.getAppUsageInfo(context)
                result.success(appUsageInfoList)
            }
            else -> {
                result.notImplemented()
            }

        }
    }
    private fun getDeviceInfo(result: MethodChannel.Result) {
        val deviceInfo = DeviceInfo.getDeviceInfo(context)
        result.success(deviceInfo)
    }
}
