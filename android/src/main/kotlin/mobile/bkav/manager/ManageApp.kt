package mobile.bkav.manager

import android.app.usage.UsageEvents
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils
import java.util.Calendar

class ManageApp {
    // Lấy thông tin các ứng dụng mặc định
    @Suppress("DEPRECATION")
    fun getAppDetailInfo(context: Context): List<Map<String, Any>> {
        val packageManager = context.packageManager
        val listApp = getListPackageName(context)
        val appDetailList = mutableListOf<Map<String, Any>>()

        for (packageName in listApp) {
            try {
                val packageInfo = packageManager.getPackageInfo(packageName, 0)
                val appName =
                    packageManager.getApplicationLabel(packageInfo.applicationInfo).toString()
                val icon = packageManager.getApplicationIcon(packageInfo.applicationInfo)
                val appIcon = Utils().drawableToByteArray(icon)
                val category = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ApplicationInfo.getCategoryTitle(context, packageInfo.applicationInfo.category)
                } else {
                    null
                }

                val appDetail = mapOf(
                    AppConstants.PACKAGE_NAME to packageInfo.packageName,
                    AppConstants.APP_NAME to appName,
                    AppConstants.APP_ICON to appIcon,
                    AppConstants.APP_CATEGORY to category.toString(),
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

    // Thời gian sử dụng trong ngày của thiết bị dùng usageState
    // Tính theo millisecond
    fun getDeviceUsage(context: Context): Long {
        val launcherApps = getListPackageName(context)
        val calendar = Calendar.getInstance()
        val startTime = getStartOfDay(calendar)
        val endTime = getEndOfDay(calendar)
        var totalTime = 0L

        val usageStatsList = appUsageTime(context, startTime, endTime)
        for (usageState in usageStatsList) {
            if (!launcherApps.contains(usageState.packageName)) continue
            totalTime += usageState.totalTimeInForeground
        }
        return totalTime
    }

    // Lấy thời gian sử dụng của các ứng dụng trong 1 khoảng thời gian
    // Trả về thời gian sử dụng của mỗi 15 phút
    // NOTE: Sử dụng UsageEvent
    fun getUsageTimeQuarterHour(
        context: Context,
        startTime: Long,
        endTime: Long
    ): Map<String, Map<Long, Long>> {
        val launcherApps = getListPackageName(context) // danh sách ứng dụng
        val usageByQuarterHourMap = mutableMapOf<String, MutableMap<Long, Long>>() // dữ liệu trả về
        val usageStatsManager = getUsageStatsManager(context) ?: return emptyMap()

        var time = startTime
        while (time < endTime) {
            // Tính thời gian sử dụng mỗi 15 phút
            val nextQuarterHour = time + 15 * 60 * 1000
            val usageEvents = usageStatsManager.queryEvents(time, nextQuarterHour)

            calculateUsageTime(usageEvents, launcherApps, usageByQuarterHourMap, time)
            time = nextQuarterHour
        }
        return usageByQuarterHourMap
    }

    // Lấy thời gian sử dụng trong ngày của từng ứng dụng dùng usageStats
    fun getTodayUsageStats(context: Context): Map<String, Map<Long, Long>> {
        val launcherApps = getListPackageName(context) // Lấy danh sách các ứng dụng hợp lệ
        val usageByQuarterHourMap = mutableMapOf<String, MutableMap<Long, Long>>()

        val usageStatsManager = getUsageStatsManager(context) ?: return emptyMap()

        // Lấy thời gian hiện tại và đầu ngày
        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis
        var startTime = getStartOfDay(calendar)

        // Lặp qua từng khoảng thời gian 15 phút
        while (startTime < endTime) {
            val nextQuarterHour = startTime + 15 * 60 * 1000
            val usageStatsList = appUsageTime(context, startTime, nextQuarterHour)
            // Xử lý từng ứng dụng trong danh sách
            usageStatsList.forEach { usageStats ->
                if (launcherApps.contains(usageStats.packageName)) {
                    val timeSpent = usageStats.totalTimeInForeground
                    val appUsageMap =
                        usageByQuarterHourMap.getOrPut(usageStats.packageName) { mutableMapOf() }
                    val currentTimeSpent = appUsageMap[startTime] ?: 0L
                    appUsageMap[startTime] = currentTimeSpent + timeSpent
                }
            }
            startTime = nextQuarterHour
        }
        return usageByQuarterHourMap
    }

    // Lấy thời gian sử dụng trong ngày hiện tại của 1 ứng dụng dùng usageStats
    fun getAppUsageTimeInMinutes(context: Context, packageName: String): Int {
        val calendar = Calendar.getInstance()
        val endTime = getEndOfDay(calendar)
        val startTime = getStartOfDay(calendar)
        val usageStatsList = appUsageTime(context, startTime, endTime)
        val appUsageStats = usageStatsList.find { it.packageName == packageName }

        // Trả về thời gian sử dụng của ứng dụng theo đơn vị phút
        return appUsageStats?.totalTimeInForeground?.div(1000)?.div(60)?.toInt() ?: 0
    }

    //  Lấy tổng thời gian sử dụng của từng ứng dụng trong [day] ngày dùng usageState
    fun getAppUsageStats(context: Context, days: Int): Map<String, Long> {
        val usageStatsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return emptyMap()
        } else {
            return emptyMap()
        }
        val calendar = Calendar.getInstance()
        val endTime = getEndOfDay(calendar)
        calendar.add(Calendar.DAY_OF_YEAR, -days + 1)
        val startTime = getStartOfDay(calendar)
        // Lấy danh sách UsageStats tổng hợp
        val aggregatedStats = usageStatsManager.queryAndAggregateUsageStats(startTime, endTime)
        // Chuyển kết quả thành Map<String, Long> với thời gian sử dụng của mỗi ứng dụng
        val usageMap = mutableMapOf<String, Long>()
        for ((packageName, usageStats) in aggregatedStats) {
            val totalTimeInForeground = usageStats.totalTimeInForeground
            if (totalTimeInForeground > 0) {
                usageMap[packageName] = totalTimeInForeground
            }
        }
        return usageMap
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


    // Hàm tính toán thời gian sử dụng cho từng ứng dụng dùng usageEvents
    private fun calculateUsageTime(
        usageEvents: UsageEvents,
        launcherApps: Set<String>,
        usageMap: MutableMap<String, MutableMap<Long, Long>>,
        currentDay: Long
    ) {
        var currentForegroundApp: String? = null
        var lastForegroundStartTime = 0L

        // Duyệt qua các sự kiện và tính toán thời gian sử dụng cho từng ứng dụng
        while (usageEvents.hasNextEvent()) {
            val event = UsageEvents.Event()
            usageEvents.getNextEvent(event)

            when (event.eventType) {
                // Xử lý sự kiện khi ứng dụng chuyển sang chế độ foreground
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    if (launcherApps.contains(event.packageName)) {
                        currentForegroundApp = event.packageName
                        lastForegroundStartTime = event.timeStamp
                    } else {
                        currentForegroundApp = null
                    }
                }
                // Xử lý sự kiện khi ứng dụng chuyển sang chế độ background
                UsageEvents.Event.ACTIVITY_PAUSED -> {
                    currentForegroundApp?.let { packageName ->
                        if (packageName == event.packageName) {
                            val timeSpent = event.timeStamp - lastForegroundStartTime
                            // Cập nhật thời gian sử dụng vào usageMap
                            usageMap.getOrPut(packageName) { mutableMapOf() }[currentDay] =
                                usageMap.getOrPut(packageName) { mutableMapOf() }[currentDay]?.let {
                                    it + timeSpent
                                } ?: timeSpent
                            currentForegroundApp = null
                        }
                    }
                }
            }
        }
    }

    // Lấy danh sách các ứng dụng đang sử dụng trong khoảng thời gian dùng usageStats
    private fun appUsageTime(context: Context, startTime: Long, endTime: Long): List<UsageStats> {
        val usageStatsManager = getUsageStatsManager(context)
        return usageStatsManager?.queryUsageStats(
            UsageStatsManager.INTERVAL_BEST,
            startTime,
            endTime
        ) ?: emptyList()
    }

    // Lấy packageName của các ứng dụng trên thiết bị
    private fun getListPackageName(context: Context): Set<String> {
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfoList = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
        } else {
            context.packageManager.queryIntentActivities(intent, 0)
        }
        return resolveInfoList.map { it.activityInfo.packageName }.toSet()
    }

    // Hàm lấy UsageStatsManager
    private fun getUsageStatsManager(context: Context): UsageStatsManager? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        } else {
            null
        }
    }
}