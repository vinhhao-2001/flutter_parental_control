package com.hao.flutter_parental_control

import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.hao.flutter_parental_control.db_helper.DBHelper
import com.hao.flutter_parental_control.model.AppUsageInfo
import com.hao.flutter_parental_control.model.DeviceInfo
import com.hao.flutter_parental_control.service.InstallAppService
import com.hao.flutter_parental_control.service.MyAccessibilityService
import com.hao.flutter_parental_control.utils.AppConstants
import com.hao.flutter_parental_control.utils.RequestPermissions
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.realm.Realm
import io.realm.RealmConfiguration


/** FlutterParentalControlPlugin */
class FlutterParentalControlPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var context: Context


    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    // Hàm thực hiện khi plugin được khởi tạo
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        initRealm() // Khởi tạo Realm

        MyAccessibilityService.setFlutterPluginBinding(flutterPluginBinding)

        // Khởi tạo MethodChannel và EventChannel
        methodChannel =
            MethodChannel(flutterPluginBinding.binaryMessenger, AppConstants.METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        val eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, AppConstants.EVENT_CHANNEL)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    // Hàm thực hiện khi plugin bị hủy
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventSink = null
    }

    // Hàm thực hiện khi có yêu cầu từ Flutter
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            AppConstants.GET_DEVICE_INFO -> {
                // Lấy thông tin thiết bị
                val deviceInfo = DeviceInfo.getDeviceInfo(context)
                result.success(deviceInfo)
            }

            AppConstants.START_SERVICE -> {
                DBHelper.insertListWebBlock(listOf("facebook", "abc"))
                DBHelper.insertListAppBlock(listOf("Cài đặt"))
                val serviceIntent = Intent(context, InstallAppService::class.java)
                context.startService(serviceIntent)
                result.success(AppConstants.EMPTY)
            }

            AppConstants.BLOCK_APP_METHOD -> {
                val blockApps =
                    call.argument<List<String>>(AppConstants.BLOCK_APPS) ?: emptyList<String>()
                DBHelper.insertListAppBlock(blockApps)
                result.success(AppConstants.EMPTY)
            }

            AppConstants.BLOCK_WEBSITE_METHOD -> {
                val blockWebsites =
                    call.argument<List<String>>(AppConstants.BLOCK_WEBSITES) ?: emptyList<String>()
                DBHelper.insertListWebBlock(blockWebsites)
                result.success(AppConstants.EMPTY)
            }

            AppConstants.GET_APP_USAGE_INFO -> {
                val appUsageInfoList = AppUsageInfo.getAppUsageInfo(context)
                result.success(appUsageInfoList)
            }

            AppConstants.GET_WEB_HISTORY -> {
                val webHistoryList = DBHelper.getWebHistory()
                result.success(webHistoryList)
            }

            AppConstants.REQUEST_PERMISSION -> {
                val type = call.argument<Int>(AppConstants.TYPE_PERMISSION)
                val requestPermissions = RequestPermissions(context)
                val isPermissionGranted = when (type) {
                    1 -> requestPermissions.requestAccessibilityPermission()
                    2 -> requestPermissions.requestOverlayPermission()
                    3 -> requestPermissions.requestUsageStatsPermissions()
                    else -> null
                }

                if (isPermissionGranted != null) {
                    result.success(isPermissionGranted)
                } else {
                    result.error("INVALID_TYPE", null, null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initRealm() {
        Realm.init(context)
        val config = RealmConfiguration.Builder()
            .name(AppConstants.REALM_NAME)
            .schemaVersion(1)
            .allowWritesOnUiThread(true)
            .allowQueriesOnUiThread(true)
            .build()
        Realm.setDefaultConfiguration(config)
    }
}
