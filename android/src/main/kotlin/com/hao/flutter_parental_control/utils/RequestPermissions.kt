package com.hao.flutter_parental_control.utils

import android.Manifest
import android.app.Activity
import android.app.AppOpsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.hao.flutter_parental_control.service.MyAccessibilityService

class RequestPermissions(private val context: Context) {

    // Hàm yêu cầu quyền truy cập trợ năng
    fun requestAccessibilityPermission(): Boolean {
        return if (!isAccessibilityPermissionGranted()) {
            openPermissionSettings(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        } else true
    }

    // Hàm yêu cầu quyền hiển thị lên màn hình
    fun requestOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(
                context
            )
        ) {
            openPermissionSettings(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:" + context.packageName)
            )
        } else true
    }

    // Hàm yêu cầu quyền truy cập thông tin sử dụng
    fun requestUsageStatsPermissions(): Boolean {
        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )

        return if (mode != AppOpsManager.MODE_ALLOWED) {
            openPermissionSettings(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        } else true
    }

    fun requestLocationPermissions(): Boolean {
        return if (ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                context as Activity,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                1
            )
            false
        } else {
            true
        }
    }


    // Kiểm tra quyền trợ năng
    private fun isAccessibilityPermissionGranted(): Boolean {
        val componentName = ComponentName(context, MyAccessibilityService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: AppConstants.EMPTY
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)

        while (colonSplitter.hasNext()) {
            val enabledService = colonSplitter.next()
            if (enabledService.equals(componentName.flattenToString(), ignoreCase = true)) {
                return true
            }
        }
        return false
    }

    private fun openPermissionSettings(settingAction: String, uri: Uri? = null): Boolean {
        // Hàm mở cài đặt để yêu cầu quyền
        val intent = Intent(settingAction, uri).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
        return false
    }
}