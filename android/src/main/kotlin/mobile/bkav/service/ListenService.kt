package mobile.bkav.service

import android.app.Service
import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.IBinder
import mobile.bkav.flutter_parental_control.FlutterParentalControlPlugin
import mobile.bkav.models.AppInstalledInfo
import mobile.bkav.receiver.AdminReceiver
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils

class ListenService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Bắt đầu service
        return START_STICKY
    }

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        // khởi tạo dịch vụ lắng nghe ứng dụng được cài đặt hoặc gỡ bỏ
        super.onCreate()
        val filter = IntentFilter()
        filter.addAction(Intent.ACTION_PACKAGE_ADDED)
        filter.addAction(Intent.ACTION_PACKAGE_REMOVED)
        filter.addAction(Intent.ACTION_SCREEN_ON)
        filter.addDataScheme(AppConstants.PACKAGE)
        registerReceiver(listenReceiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(listenReceiver)
    }

    // Hàm thực hiện khi có ứng dụng được cài đặt hoặc gỡ bỏ
    private val listenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.action
            val packageName = intent?.data?.schemeSpecificPart
            if (packageName != null && context != null) {
                when (action) {
                    Intent.ACTION_PACKAGE_ADDED -> {
                        val appName = context.packageManager.getApplicationLabel(
                            context.packageManager.getApplicationInfo(packageName, 0)
                        ).toString()
                        val appIcon = context.packageManager.getApplicationIcon(
                            context.packageManager.getApplicationInfo(packageName, 0)
                        )
                        val icon = Utils().drawableToByteArray(appIcon)
                        val appInstalledInfo = AppInstalledInfo(true, packageName, appName, icon)
                        FlutterParentalControlPlugin.eventSink?.success(appInstalledInfo.toMap())
                    }

                    Intent.ACTION_PACKAGE_REMOVED -> {
                        val appInstalledInfo =
                            AppInstalledInfo(false, packageName, AppConstants.EMPTY, byteArrayOf())
                        FlutterParentalControlPlugin.eventSink?.success(appInstalledInfo.toMap())
                    }

                    Intent.ACTION_SCREEN_ON -> {
                        println("Tắt máy")
                        val devicePolicyManager =
                            context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                        val componentName = ComponentName(context, AdminReceiver::class.java)
                        if (devicePolicyManager.isAdminActive(componentName)) {

                            devicePolicyManager.lockNow()
                        }
                    }
                }
            }
        }
    }
}