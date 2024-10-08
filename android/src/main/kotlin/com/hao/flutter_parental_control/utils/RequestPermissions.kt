package com.hao.flutter_parental_control.utils

import android.app.AppOpsManager

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import android.widget.Toast
import com.hao.flutter_parental_control.service.MyAccessibilityService

class RequestPermissions(private val context: Context) {

    // Hàm yêu cầu quyền truy cập trợ năng
    fun requestAccessibilityPermission() {
        if (!isAccessibilityPermissionGranted()) {
            // Mở cài đặt trợ năng nếu chưa được cấp quyền
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        } else {
            Toast.makeText(context, "Quyền trợ năng đã được cấp!", Toast.LENGTH_SHORT).show()
        }
    }

    // Hàm yêu cầu quyền hiển thị lên màn hình
    fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(context)) {
                // Mở cài đặt quyền hiển thị nếu chưa được cấp quyền
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + context.packageName)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
            } else {
                Toast.makeText(context, "Quyền hiển thị đã được cấp!", Toast.LENGTH_SHORT).show()
            }
        } else {
            Toast.makeText(context, "Quyền hiển thị không yêu cầu trên Android trước Marshmallow!", Toast.LENGTH_SHORT).show()
        }
    }

    // Hàm yêu cầu quyền truy cập thông tin sử dụng
    fun requestUsageStatsPermissions() {
        val appOpsManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOpsManager.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            context.packageName
        )

        if (mode != AppOpsManager.MODE_ALLOWED) {
            // Mở cài đặt quyền truy cập thông tin sử dụng nếu chưa được cấp quyền
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        } else {
            Toast.makeText(context, "Quyền truy cập thông tin sử dụng đã được cấp!", Toast.LENGTH_SHORT).show()
        }
    }

    // Kiểm tra quyền trợ năng
    private fun isAccessibilityPermissionGranted(): Boolean {
        val componentName = ComponentName(context, MyAccessibilityService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: ""
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
}

