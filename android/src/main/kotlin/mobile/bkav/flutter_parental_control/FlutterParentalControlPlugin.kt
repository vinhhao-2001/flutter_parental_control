package mobile.bkav.flutter_parental_control

import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.realm.Realm
import io.realm.RealmConfiguration
import mobile.bkav.db_helper.DBHelper
import mobile.bkav.manager.ManagerApp
import mobile.bkav.models.DeviceInfo
import mobile.bkav.service.AccessibilityService
import mobile.bkav.service.InstallAppService
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.RequestPermissions


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

        AccessibilityService.setFlutterPluginBinding(flutterPluginBinding)

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
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            AppConstants.GET_DEVICE_INFO -> {
                // Lấy thông tin thiết bị
                val deviceInfo = DeviceInfo.getDeviceInfo(context)
                result.success(deviceInfo)
            }

            AppConstants.GET_APP_DETAIL -> {
                // Lấy thông tin các ứng dụng được cài đặt
                val appDetailInfo = ManagerApp().getAppDetailInfo(context)
                result.success(appDetailInfo)
            }

            AppConstants.START_SERVICE -> {
                // Bắt đầu lắng nghe ứng dụng được cài đặt, gỡ bỏ
                val serviceIntent = Intent(context, InstallAppService::class.java)
                context.startService(serviceIntent)
                result.success(AppConstants.EMPTY)
            }

            AppConstants.BLOCK_APP_METHOD -> {
                // Thêm ứng dụng bị chặn vào danh sách ứng dụng bị chặn
                val blockApps =
                    call.argument<List<Map<String, Any>>>(AppConstants.BLOCK_APPS)
                        ?: emptyList<Map<String, Any>>()
                DBHelper.insertListAppBlock(context, blockApps)
                result.success(AppConstants.EMPTY)
            }

            AppConstants.BLOCK_WEBSITE_METHOD -> {
                // Thêm trang web bị chặn vào danh sách trang web bị chặn
                val blockWebsites =
                    call.argument<List<String>>(AppConstants.BLOCK_WEBSITES) ?: emptyList<String>()
                DBHelper.insertListWebBlock(blockWebsites)
                result.success(AppConstants.EMPTY)
            }

            AppConstants.GET_APP_USAGE_INFO -> {
                // Lấy thông tin sử dụng ứng dụng
                val appUsageInfoList = ManagerApp().getAppUsageInfo(context)
                result.success(appUsageInfoList)
            }

            AppConstants.GET_WEB_HISTORY -> {
                // Lấy lịch sử duyệt web
                val webHistoryList = DBHelper.getWebHistory()
                result.success(webHistoryList)
            }

            AppConstants.REQUEST_PERMISSION -> {
                // Yêu cầu quyền cho ứng dụng
                val type = call.argument<Int>(AppConstants.TYPE_PERMISSION)
                val requestPermissions = RequestPermissions(context)

                when (type) {
                    1 -> result.success(requestPermissions.requestAccessibilityPermission())
                    2 -> result.success(requestPermissions.requestOverlayPermission())
                    3 -> result.success(requestPermissions.requestUsageStatsPermissions())
                    else -> result.error(AppConstants.ERROR_TYPE_PERMISSION, null, null)
                }
            }

            AppConstants.OVERLAY_METHOD -> {
                // lấy thông tin overlay từ flutter và lưu vào db
                val id = call.argument<Boolean>(AppConstants.ID)
                val overlayView = call.argument<String>(AppConstants.OVERLAY_VIEW)
                val backBtn = call.argument<String>(AppConstants.BACK_BTN)
                val askParentBtn = call.argument<String?>(AppConstants.ASK_PARENT_BTN)
                if (id != null && overlayView != null && backBtn != null) {
                    DBHelper.insertOverlayView(id, overlayView, backBtn, askParentBtn)
                }
                result.success(AppConstants.EMPTY)
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
