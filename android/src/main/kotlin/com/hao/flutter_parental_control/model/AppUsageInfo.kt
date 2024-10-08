package com.hao.flutter_parental_control.model

import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import com.hao.flutter_parental_control.utils.Utils
import java.util.Calendar

data class AppUsageInfo(
    val name: String,
    val packageName: String,
    val icon: ByteArray,
    val usageTime: Long
) {
    companion object {
        fun getAppUsageInfo(context: Context): List<Map<String, Any>> {
            val calendar = Calendar.getInstance()
            calendar.add(Calendar.DAY_OF_YEAR, -1)
            val endTime = System.currentTimeMillis()
            val startTime = calendar.timeInMillis

            val usageStatsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                context.getSystemService(Context.USAGE_STATS_SERVICE)
                        as UsageStatsManager
            } else {
                return emptyList()
            }
            val usageStatsList = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            ) ?: emptyList()

            val appUsageInfoList = mutableListOf<Map<String, Any>>()

            // Tạo intent để lấy các ứng dụng có thể hiển thị trên launcher
            val intent = Intent(Intent.ACTION_MAIN, null)
            intent.addCategory(Intent.CATEGORY_LAUNCHER)
            val resolveInfoList = context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)

            // Tạo danh sách các packageName của ứng dụng có thể hiển thị
            val launcherApps = resolveInfoList.map { it.activityInfo.packageName }.toSet()

            for (usageStats in usageStatsList) {
                try {
                    if (!launcherApps.contains(usageStats.packageName)) {
                        continue
                    }

                    val appInfo = context.packageManager.getApplicationInfo(usageStats.packageName, 0)
                    val appName = context.packageManager.getApplicationLabel(appInfo).toString()
                    val icon = context.packageManager.getApplicationIcon(appInfo)
                    val appIcon = Utils().drawableToByteArray(icon)
                    val appUsageInfo = mapOf(
                        "appName" to appName,
                        "packageName" to usageStats.packageName,
                        "appIcon" to appIcon,
                        "usageTime" to usageStats.totalTimeInForeground
                    )
                    appUsageInfoList.add(appUsageInfo)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            return appUsageInfoList
        }
    }

}


