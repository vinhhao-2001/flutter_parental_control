package mobile.bkav.manager

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils
import java.util.Calendar

class ManagerApp {
    // Lấy thông tin các ứng dụng mặc định
    @Suppress("DEPRECATION")
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

    // Thời gian sử dụng của thiết bị
    // Tính theo millisecond
    fun getDeviceUsage(context: Context): Long {
        val launcherApps = getLauncherAppPackages(context)
        val calendar = Calendar.getInstance()
        val startTime = getStartOfDay(calendar)
        val endTime = getEndOfDay(calendar)
        var totalTime = 0L

        val usageStatsList = Utils().appUsageTime(context, startTime, endTime)
        for (usageState in usageStatsList) {
            if (!launcherApps.contains(usageState.packageName)) continue
            totalTime += usageState.totalTimeInForeground
        }
        return totalTime
    }

    // Lấy thời gian sử dụng trong ngày hôm nay
    fun getTodayUsage(context: Context): Map<String, Map<Long, Long>> {
        val launcherApps = getLauncherAppPackages(context)
        val usageByQuarterHourMap = mutableMapOf<String, MutableMap<Long, Long>>()
        // Tạo khoảng thời điểm để lấy thời gian sử dụng
        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis
        var startTime = getStartOfDay(calendar)

        val usageStatsManager = getUsageStatsManager(context) ?: return emptyMap()

        while (startTime < endTime) {
            val nextQuarterHour = startTime + 15 * 60 * 1000
            val usageEvents = usageStatsManager.queryEvents(startTime, nextQuarterHour)

            calculateUsageTime(usageEvents, launcherApps, usageByQuarterHourMap, startTime)
            startTime = nextQuarterHour
        }
        return usageByQuarterHourMap
    }

    //  Lấy danh sách thời gian sử dụng trong ngày
    fun getAppUsageStats(context: Context, days: Int): Map<String, Long> {
        val usageStatsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return emptyMap()
        } else {
            return emptyMap()
        }

        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -days + 1)

        val startTime = getStartOfDay(calendar)
        val endTime = getEndOfDay(calendar)


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

    // Hàm lấy UsageStatsManager
    private fun getUsageStatsManager(context: Context): UsageStatsManager? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        } else {
            null // API<22 không được hỗ trợ
        }
    }

    // Hàm tính toán thời gian sử dụng cho từng ứng dụng
    @Suppress("DEPRECATION")
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
                // Xử lý sự kiện khi ứng dụng chuyển sang chế độ foreground
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    if (launcherApps.contains(event.packageName)) {
                        currentForegroundApp = event.packageName
                        lastForegroundStartTime = event.timeStamp
                    } else {
                        currentForegroundApp = null
                    }
                }
                // Xử lý sự kiện khi ứng dụng chuyển sang chế độ background
                UsageEvents.Event.MOVE_TO_BACKGROUND -> {
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

    // Lấy danh sách ứng dụng trên thiết bị
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