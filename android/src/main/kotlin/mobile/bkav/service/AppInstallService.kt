package mobile.bkav.service

import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.IBinder
import mobile.bkav.flutter_parental_control.FlutterParentalControlPlugin
import mobile.bkav.models.AppInstalledInfo
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils

class AppInstallService : Service() {

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
        filter.addDataScheme(AppConstants.PACKAGE)
        registerReceiver(appInstallReceiver, filter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(appInstallReceiver)
    }

    // Hàm thực hiện khi có ứng dụng được cài đặt hoặc gỡ bỏ
    private val appInstallReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.action
            val packageName = intent?.data?.schemeSpecificPart
            if (packageName != null && context != null) {
                // Nếu là ứng dụng hệ thống thì bỏ qua
                if (!isUserInstalledApp(context, packageName)) {
                    return
                }

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
                }
            }
        }
    }

    // Kiểm tra ứng dụng được cài đặt
    private fun isUserInstalledApp(context: Context, packageName: String): Boolean {
        return try {
            val appInfo = context.packageManager.getApplicationInfo(packageName, 0)
            (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) == 0
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}