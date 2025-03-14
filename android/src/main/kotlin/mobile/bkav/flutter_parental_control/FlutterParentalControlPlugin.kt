package mobile.bkav.flutter_parental_control

import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.realm.Realm
import io.realm.RealmConfiguration
import mobile.bkav.db_helper.DBHelper
import mobile.bkav.manager.ManageApp
import mobile.bkav.manager.ManageDevice
import mobile.bkav.receiver.AdminReceiver
import mobile.bkav.service.AppInstallService
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.RequestPermissions


/** FlutterParentalControlPlugin */
class FlutterParentalControlPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var methodChannel: MethodChannel
    private lateinit var activityBinding: Activity
    private lateinit var context: Context

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    // Hàm thực hiện khi plugin được khởi tạo
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        initRealm() // Khởi tạo Realm

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

        // Khởi tạo broadcast để hỏi phụ huynh
        val filter = IntentFilter(AppConstants.ACTION_ASK_PARENT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(broadcastReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(broadcastReceiver, filter)
        }
    }

    // Hàm thực hiện khi plugin bị hủy
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventSink = null
    }

    // Hàm thực hiện khi có yêu cầu từ Flutter
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            // Cho phép xoá ứng dụng hay không
            AppConstants.SET_REMOVE_MY_APP -> {
                val allowRemoveApp = call.argument<Boolean>(AppConstants.SET_REMOVE_MY_APP) ?: false
               println(allowRemoveApp)
                DBHelper.setRemoveApp(context, allowRemoveApp)
                result.success(null)
            }

            // Yêu cầu các quyền cho ứng dụng
            AppConstants.REQUEST_PERMISSION -> {
                val type = call.argument<Int>(AppConstants.TYPE_PERMISSION)
                val requestPermissions = RequestPermissions(context)
                when (type) {
                    1 -> result.success(requestPermissions.requestAccessibilityPermission())
                    2 -> result.success(requestPermissions.requestOverlayPermission())
                    3 -> result.success(requestPermissions.requestUsageStatsPermissions())
                    4 -> result.success(requestAdminPermission())
                    else -> result.error(AppConstants.ERROR_TYPE_PERMISSION, null, null)
                }
            }

            // Gửi các thông tin thiết bị cho Flutter
            AppConstants.GET_DEVICE_INFO -> {
                val deviceInfo = ManageDevice().getDeviceInfo(context)
                result.success(deviceInfo)
            }

            // Gửi các thông tin trạng thái thiết bị: pin, độ sáng, âm lượng
            AppConstants.GET_DEVICE_STATE -> {
                val deviceState = ManageDevice().getDeviceState(context)
                result.success(deviceState)
            }

            AppConstants.GET_DEVICE_IDENTIFY -> {
                val deviceId = ManageDevice().getDeviceIdentify(context)
                result.success(deviceId)
            }

            // Gửi thông tin các ứng dụng được cài đặt ra Flutter
            AppConstants.GET_APP_DETAIL -> {
                val appDetailInfo = ManageApp().getAppDetailInfo(context)
                result.success(appDetailInfo)
            }

            // Gửi tổng thời gian sử dụng của thiết bị trong ngày ra Flutter
            AppConstants.GET_DEVICE_USAGE -> {
                val deviceUsage = ManageApp().getDeviceUsage(context)
                result.success(deviceUsage)
            }

            // Gửi thời gian sử dụng thiết bị trong 1 khoảng thời gian theo mỗi 15 phút ra Flutter
            AppConstants.GET_USAGE_TIME_QUARTER_HOUR -> {
                val startTime = call.argument<Long>(AppConstants.START_TIME)
                val endTime = call.argument<Long>(AppConstants.END_TIME)
                if (startTime != null && endTime != null) {
                    val appUsageInfoList =
                        ManageApp().getUsageTimeQuarterHour(context, startTime, endTime)
                    result.success(appUsageInfoList)
                }
            }

            // Gửi tổng thời gian sử dụng của từng ứng dụng ra Flutter
            AppConstants.GET_APP_USAGE_INFO -> {
                val day = call.argument<Int>(AppConstants.DAY) ?: 1
                val appUsageInfoList = ManageApp().getAppUsageStats(context, day)
                result.success(appUsageInfoList)
            }

            // Lấy thời gian và khoảng thời gian được phép sử dụng trong ngày
            AppConstants.SET_DEVICE_TIME_ALLOW -> {
                val timeAllow = call.argument<Int>(AppConstants.TIME_ALLOW) ?: null
                val timePeriod =
                    call.argument<List<Map<String, Any>>>(AppConstants.TIME_PERIOD) ?: null
                DBHelper.insertTimeAllowed(timeAllow, timePeriod)
            }

            // Tạo danh sách ứng dụng bị chặn
            AppConstants.SET_BLOCK_APP_METHOD -> {
                val blockApps =
                    call.argument<List<Map<String, Any>>>(AppConstants.BLOCK_APPS)
                        ?: emptyList<Map<String, Any>>()
                val addNew = call.argument<Boolean>(AppConstants.ADD_NEW) ?: false
                DBHelper.insertAppBlock(context, blockApps, addNew)
                result.success(null)
            }

            // Tạo danh sách ứng dụng luôn được phép sử dụng
            AppConstants.SET_ALWAYS_USE_APP_METHOD -> {
                val alwaysUseApps =
                    call.argument<List<String>>(AppConstants.ALWAYS_USE_APPS) ?: emptyList<String>()
                DBHelper.insertAppAlwaysUse(context, alwaysUseApps)
                result.success(null)
            }

            // Tạo danh sách trang web bị chặn
            AppConstants.SET_BLOCK_WEBSITE_METHOD -> {
                val blockWebsites =
                    call.argument<List<String>>(AppConstants.BLOCK_WEBSITES) ?: emptyList<String>()
                val addNew = call.argument<Boolean>(AppConstants.ADD_NEW) ?: false
                DBHelper.insertWebBlock(blockWebsites, addNew)
                result.success(null)
            }

            // Gửi lịch sử duyệt web ra Flutter
            AppConstants.GET_WEB_HISTORY -> {
                val webHistoryList = DBHelper.getWebHistory()
                result.success(webHistoryList)
            }

            // Khoá màn hình thiết bị
            AppConstants.LOCK_DEVICE -> {
                val devicePolicyManager =
                    context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                val componentName = ComponentName(context, AdminReceiver::class.java)
                if (devicePolicyManager.isAdminActive(componentName)) {
                    devicePolicyManager.lockNow()
                } else {
                    Log.d("LOCK_DEVICE", "Need Device Admin Permission")
                }
                result.success(null)
            }

            // lấy thông tin của overlay
            AppConstants.SET_OVERLAY_METHOD -> {
                val id = call.argument<Boolean>(AppConstants.ID)
                val overlayView = call.argument<String>(AppConstants.OVERLAY_VIEW)
                val backBtn = call.argument<String>(AppConstants.BACK_BTN)
                val askParentBtn = call.argument<String?>(AppConstants.ASK_PARENT_BTN)

                if (id != null && overlayView != null && backBtn != null) {
                    DBHelper.insertOverlayView(id, overlayView, backBtn, askParentBtn)
                }
                result.success(null)
            }

            // Kích hoạt dịch vụ lắng nghe ứng dụng được cài đặt, gỡ bỏ
            AppConstants.START_SERVICE -> {
                val serviceIntent = Intent(context, AppInstallService::class.java)
                context.startService(serviceIntent)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    // Của ActivityAware
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    // Hàm thực hiện khi Activity bị thay đổi cấu hình
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    // Hàm thực hiện khi Activity bị hủy
    override fun onDetachedFromActivity() {
    }

    // Khởi tạo realmDB
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

    // Xin quyền admin
    private fun requestAdminPermission(): Boolean {
        val devicePolicyManager =
            activityBinding.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val componentName = ComponentName(activityBinding, AdminReceiver::class.java)

        return if (!devicePolicyManager.isAdminActive(componentName)) {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
                putExtra(
                    DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                    "Device Admin Permission required for this app."
                )
            }
            activityBinding.startActivityForResult(intent, 1000)
            false
        } else {
            true
        }
    }

    // Tạo broadcast để đưa thông tin yêu cầu phụ huynh từ service -> Flutter
    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val packageName = intent.getStringExtra(AppConstants.PACKAGE_NAME)
            val appName = intent.getStringExtra(AppConstants.APP_NAME)
            if (packageName != null && appName != null) {
                methodChannel.invokeMethod(
                    AppConstants.ASK_PARENT_METHOD,
                    mapOf(
                        AppConstants.PACKAGE_NAME to packageName,
                        AppConstants.APP_NAME to appName,
                    )
                )
            }
        }
    }
}
