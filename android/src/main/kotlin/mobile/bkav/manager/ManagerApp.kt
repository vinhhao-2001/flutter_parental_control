package mobile.bkav.manager

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils
import java.util.Calendar

class ManagerApp {
    // Lấy thông tin các ứng dụng mặc định
    fun getAppDetailInfo(context: Context): List<Map<String, Any>> {
        val packageManager = context.packageManager
        val listApp = getLauncherAppPackages(context)
        val appDetailList = mutableListOf<Map<String, Any>>()

        for (packageName in listApp) {
            try {
                val packageInfo = packageManager.getPackageInfo(packageName, 0)
                val appName =
                    packageManager.getApplicationLabel(packageInfo.applicationInfo).toString()
                val icon = packageManager.getApplicationIcon(packageInfo.applicationInfo)
                val appIcon = Utils().drawableToByteArray(icon)

                val appDetail = mapOf(
                    AppConstants.PACKAGE_NAME to packageInfo.packageName,
                    AppConstants.APP_NAME to appName,
                    AppConstants.APP_ICON to appIcon,
                    AppConstants.VERSION_CODE to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        packageInfo.longVersionCode
                    } else {
                        packageInfo.versionCode.toLong()
                    },
                    AppConstants.VERSION_NAME to (packageInfo.versionName ?: AppConstants.EMPTY),
                    AppConstants.TIME_INSTALL to packageInfo.firstInstallTime,
                    AppConstants.TIME_UPDATE to packageInfo.lastUpdateTime
                )
                appDetailList.add(appDetail)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return appDetailList
    }

    // Lấy thời gian sử dụng của các ứng dụng dùng UsageState
    fun getAppUsageInfo(context: Context): Map<String, Map<Long, Long>> {
        val launcherApps = getLauncherAppPackages(context)
        val appUsageInfoMap = mutableMapOf<String, MutableMap<Long, Long>>()
        val calendar = Calendar.getInstance()

        for (i in 0 until 7) {
            val startTime = getStartOfDay(calendar)
            val endTime = getEndOfDay(calendar)

            // Lấy dữ liệu sử dụng cho ngày cụ thể
            val usageStatsList = Utils().appUsageTime(context, startTime, endTime)
            for (usageStats in usageStatsList) {
                if (!launcherApps.contains(usageStats.packageName)) continue
                val dailyUsageMap =
                    appUsageInfoMap.getOrPut(usageStats.packageName) { mutableMapOf() }
                // Thêm thời gian sử dụng cho ngày cụ thể vào `Map` thời gian sử dụng
                dailyUsageMap[startTime] =
                    (dailyUsageMap[startTime] ?: 0) + usageStats.totalTimeInForeground
            }
            // Lùi lại 1 ngày để chuẩn bị tính startTime và endTime cho ngày trước đó
            calendar.add(Calendar.DAY_OF_YEAR, -1)
        }
        return appUsageInfoMap
    }

    // Lấy thời gian sử dụng của các ứng dụng dùng UsageEvent
    fun getAppUsageInfo(context: Context, day: Int): Map<String, Map<Long, Long>> {
        val launcherApps = getLauncherAppPackages(context)
        val usageByAppMap = mutableMapOf<String, MutableMap<Long, Long>>() // Cấu trúc mới

        val calendar = Calendar.getInstance()

        for (i in 0 until day) {
            val startDay = getStartOfDay(calendar) // Thời gian bắt đầu ngày 0h00
            val endDay = getEndOfDay(calendar) // Thời gian kết thúc ngày 23h59
            val usageStatsManager = getUsageStatsManager(context) ?: return emptyMap()

            val usageEvents = usageStatsManager.queryEvents(startDay, endDay)

            calculateUsageTime(usageEvents, launcherApps, usageByAppMap, startDay)
            calendar.add(Calendar.DAY_OF_YEAR, -1)
        }
        return usageByAppMap
    }

    // Hàm lấy thời gian bắt đầu của ngày
    private fun getStartOfDay(calendar: Calendar): Long {
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        return calendar.timeInMillis
    }

    // Hàm lấy thời gian kết thúc của ngày
    private fun getEndOfDay(calendar: Calendar): Long {
        calendar.set(Calendar.HOUR_OF_DAY, 23)
        calendar.set(Calendar.MINUTE, 59)
        calendar.set(Calendar.SECOND, 59)
        calendar.set(Calendar.MILLISECOND, 999)
        return calendar.timeInMillis
    }

    // Hàm lấy UsageStatsManager
    private fun getUsageStatsManager(context: Context): UsageStatsManager? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        } else {
            null // API<22 không được hỗ trợ
        }
    }

    // Hàm tính toán thời gian sử dụng cho từng ứng dụng
    private fun calculateUsageTime(
        usageEvents: UsageEvents,
        launcherApps: Set<String>,
        usageMap: MutableMap<String, MutableMap<Long, Long>>, // Thay đổi kiểu
        currentDay: Long // Thời gian bắt đầu của ngày hiện tại
    ) {
        var currentForegroundApp: String? = null
        var lastForegroundStartTime = 0L

        // Duyệt qua các sự kiện và tính toán thời gian sử dụng cho từng ứng dụng
        while (usageEvents.hasNextEvent()) {
            val event = UsageEvents.Event()
            usageEvents.getNextEvent(event)

            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    if (launcherApps.contains(event.packageName)) {
                        currentForegroundApp = event.packageName
                        lastForegroundStartTime = event.timeStamp
                    } else {
                        currentForegroundApp = null
                    }
                }

                UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                    currentForegroundApp?.let { packageName ->
                        if (packageName == event.packageName) {
                            val totalTimeInForeground = event.timeStamp - lastForegroundStartTime
                            // Cập nhật thời gian sử dụng vào usageMap
                            usageMap.getOrPut(packageName) { mutableMapOf() }[currentDay] =
                                usageMap.getOrPut(packageName) { mutableMapOf() }[currentDay]?.let {
                                    it + totalTimeInForeground
                                } ?: totalTimeInForeground
                            currentForegroundApp = null
                        }
                    }
                }
            }
        }
    }

    private fun getLauncherAppPackages(context: Context): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfoList = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
        } else {
            context.packageManager.queryIntentActivities(intent, 0)
        }
        return resolveInfoList.map { it.activityInfo.packageName }.toSet()
    }
}