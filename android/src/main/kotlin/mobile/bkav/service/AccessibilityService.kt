package mobile.bkav.service

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mobile.bkav.db_helper.DBHelper
import mobile.bkav.manager.ManageApp
import mobile.bkav.models.SupportedBrowserConfig
import mobile.bkav.overlay.Overlay
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils


// Dịch vụ trợ năng
class AccessibilityService : AccessibilityService() {

    // Khai báo các biến dùng nhiều trong ứng dụng
    private lateinit var homePackageName: String
    private lateinit var settingPackageName: String
    private var currentBrowserPackageName: String = AppConstants.EMPTY
    private var currentUrl: String = AppConstants.EMPTY
    private val coroutineScope = CoroutineScope(Dispatchers.IO)
    private lateinit var overlay: Overlay

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Xử lý khi service đươc kết nối
        homePackageName = getPackageNameForIntent(Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }) ?: AppConstants.EMPTY
        settingPackageName =
            getPackageNameForIntent(Intent(Settings.ACTION_SETTINGS)) ?: AppConstants.EMPTY
        overlay = Overlay(this)
        checkTimeDeviceAllow()
    }

    override fun onInterrupt() {
        // Xử lý khi service bị ngắt
    }

    // Xử lý sự kiện Accessibility
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        packageName
        event?.let { accessibilityEvent ->
            val packageName = accessibilityEvent.packageName?.toString() ?: return
            when (accessibilityEvent.eventType) {
                // Giám sát sự kiện trình duyệt
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED, AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
                -> handleWindowChange(accessibilityEvent)
                // Sự kiện khi ở trong màn hình chính

                else -> if (packageName == homePackageName) {
                    handleLauncherEvent(accessibilityEvent)
                } else if (packageName == settingPackageName) {
                    handleSettingEvent(accessibilityEvent)
                }
            }
        }
    }

    private fun handleLauncherEvent(accessibilityEvent: AccessibilityEvent) {
        // Kiểm tra sự kiện khi người dùng nhấn vào ứng dụng ở màn hình chính
        val contentDescription = accessibilityEvent.contentDescription?.toString() ?: return

        // Kiểm tra sự kiện người dùng muốn xóa ứng dụng
        if (accessibilityEvent.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED) {
            // Lấy tên của ứng dụng của bạn
            val appName = Utils().getApplicationName(applicationContext)
            if (contentDescription.contains(appName)) {
                overlay.showOverlay(false) {
                    Utils().openApp(applicationContext)
                    askParent(packageName, appName)
                }
            }
        } else {
            // Kiểm tra nếu ứng dụng bị chặn
            val appName = contentDescription.substringBefore(",").trim()
            val packageName = DBHelper.getPackageAppBlock(applicationContext, appName)
            if (packageName != null) {
                // Hiển thị màn hình chặn
                overlay.showOverlay(true) {
                    Utils().openApp(applicationContext)
                    askParent(packageName, appName)
                }
            }
        }
    }

    // Hàm xử lý sự kiện khi người dùng mở trình duyệt
    @Suppress("DEPRECATION")
    private fun handleWindowChange(accessibilityEvent: AccessibilityEvent) {
        // Kiểm tra khi có sự kiên chuyển màn hình
        val packageName: String = accessibilityEvent.packageName?.toString() ?: return
        val appName = DBHelper.getAppBlock(applicationContext, packageName)
        // khi chuyển màn hình mà vào app bị chặn cũng hiển thị màn hình chặn
        if (appName != null) {
            overlay.showOverlay(true) {
                Utils().openApp(applicationContext)
                askParent(packageName, appName)
            }
        }
        // Kiểm tra sự kiện khi chuyển trang trong các ứng dụng web
        else {
            val parentNodeInfo: AccessibilityNodeInfo = accessibilityEvent.source ?: return
            val browserConfig = getBrowserConfig(packageName) ?: return

            // Url của trình duyệt
            val capturedUrl: String? = extractUrlFromBrowser(parentNodeInfo, browserConfig)
            parentNodeInfo.recycle()

            if (!capturedUrl.isNullOrEmpty() && (packageName != currentBrowserPackageName || capturedUrl != currentUrl)) {
                currentBrowserPackageName = packageName
                currentUrl = capturedUrl

                // Lưu lịch sử duyệt web của trẻ
                DBHelper.insertWebHistory(capturedUrl)

                // Kiểm tra nếu URL bị chặn
                if (DBHelper.isUrlBlocked(capturedUrl)) {
                    redirectToBlankPage()
                }
            }
        }

    }

    // Lắng nghe ứng dụng trong cài đặt
    private fun handleSettingEvent(accessibilityEvent: AccessibilityEvent) {
        if (accessibilityEvent.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
            println(accessibilityEvent)
            val appName = Utils().getApplicationName(applicationContext)
            if (accessibilityEvent.text.any { it.contains(appName) }) {
                // Thoát ra
                this.performGlobalAction(GLOBAL_ACTION_BACK)
                this.performGlobalAction(GLOBAL_ACTION_HOME)
            }
        }
    }

    // Hàm lấy cấu hình trình duyệt
    private fun getBrowserConfig(packageName: String): SupportedBrowserConfig? {
        return SupportedBrowserConfig.getSupportedBrowsers().find { it.packageName == packageName }
    }

    // Hàm trích xuất URL từ trình duyệt
    private fun extractUrlFromBrowser(
        nodeInfo: AccessibilityNodeInfo, browserConfig: SupportedBrowserConfig
    ): String? {
        // Lấy URL từ thanh địa chỉ của trình duyệt
        return nodeInfo.findAccessibilityNodeInfosByViewId(browserConfig.addressBarId)
            .firstOrNull()?.text?.toString()
    }

    // Hàm chuyển hướng đến trang trắng
    private fun redirectToBlankPage() {
        val blankPageUri = Uri.parse(AppConstants.BLANK_PAGE)
        val intent = Intent(Intent.ACTION_VIEW, blankPageUri).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        applicationContext.startActivity(intent)
    }

    private fun askParent(packageName: String, appName: String) {
        val intent = Intent()
        // Gửi thông tin cho flutter
        intent.action = AppConstants.ACTION_ASK_PARENT
        intent.putExtra(AppConstants.PACKAGE_NAME, packageName)
        intent.putExtra(AppConstants.APP_NAME, appName)
        sendBroadcast(intent)
    }

    // Kiểm tra còn thời gian được phép sử dụng không
    private fun checkTimeDeviceAllow() {
        coroutineScope.launch {
            val timeUsed = ManageApp().getDeviceUsage(this@AccessibilityService)
            val timeAllow = DBHelper.getTimeAllow(timeUsed)
            val timePeriod = DBHelper.timePeriodValid()
            while (true) {
                if (timeAllow.second && timePeriod.second) {
                    if (timeAllow.first > timePeriod.first) {
                        delay(timePeriod.first)
                    } else {
                        delay(timeAllow.first)
                    }
                } else {
                    withContext(Dispatchers.Main) {
                        overlay.showExpiredTimeOverlay(timePeriod.first)
                    }
                    break
                }
            }
        }
    }

    private fun getPackageNameForIntent(intent: Intent): String? {
        val resolveInfo =
            this.packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName
    }
}
