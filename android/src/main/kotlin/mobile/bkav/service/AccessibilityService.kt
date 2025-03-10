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
import mobile.bkav.models.BrowserConfig
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

    // Xử lý khi service đươc kết nối
    override fun onServiceConnected() {
        super.onServiceConnected()
        // Lấy tên packageName của launcher
        homePackageName = getPackageNameForIntent(Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }) ?: AppConstants.EMPTY

        // Lấy tên packageName của cài đặt
        settingPackageName =
            getPackageNameForIntent(Intent(Settings.ACTION_SETTINGS)) ?: AppConstants.EMPTY

        // Khởi tạo overlay
        overlay = Overlay(this)

        // TODO: Check thời gian sử dụng còn lại,
        //  cần sửa để chỉ chặn sử dụng thiết bị chứ không chặn điện thoại
        // checkTimeDeviceAllow()
    }

    // Xử lý khi service bị ngắt
    override fun onInterrupt() {}

    // Xử lý sự kiện Accessibility
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        packageName
        event?.let { accessibilityEvent ->
            val packageName = accessibilityEvent.packageName?.toString() ?: return
            when (accessibilityEvent.eventType) {
                // Giám sát sự kiện chuyển màn hình
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED, AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
                -> handleWindowChange(accessibilityEvent)

                // Sự kiện khi ở trong màn hình chính
                else -> if (packageName == homePackageName) {
                    handleLauncherEvent(accessibilityEvent)
                }

                // Sự kiện khi ở trong cài đặt
                else if (packageName == settingPackageName) {
                    handleSettingEvent(accessibilityEvent)
                }
            }
        }
    }

    // Kiểm tra sự kiện khi người dùng nhấn vào ứng dụng ở màn hình chính
    private fun handleLauncherEvent(accessibilityEvent: AccessibilityEvent) {
        val contentDescription = accessibilityEvent.contentDescription?.toString() ?: return

        // Mỗi khi có sự kiện click thì kiểm tra thời gian sử dụng còn lại
        if (accessibilityEvent.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
            val checkTime = DBHelper.isDeviceAllow(applicationContext)
            if (!checkTime) {
                // TODO: Chặn và gửi 1 thông báo
                overlay.showExpiredTimeOverlay(0)
            }
        } else
        // Kiểm tra sự kiện người dùng muốn xóa ứng dụng: Sự kiến nhấn vào app
            if (accessibilityEvent.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED) {
                // Lấy tên của ứng dụng của bạn
                val appName = Utils().getMyAppName(applicationContext)
                if (contentDescription.contains(appName)) {
                    overlay.showOverlay(false) {
                        Utils().openApp(applicationContext)
                        askParent(packageName, appName)
                    }
                }
            }
            // Kiểm tra nếu ứng dụng bị chặn
            else {
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

    // Hàm xử lý khi có sự kiện chuyển màn hình
    @Suppress("DEPRECATION")
    private fun handleWindowChange(accessibilityEvent: AccessibilityEvent) {
        val packageName: String = accessibilityEvent.packageName?.toString() ?: return
        val appName = DBHelper.getAppBlock(applicationContext, packageName)

        // khi chuyển màn hình mà vào app bị chặn thì hiển thị màn hình chặn
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

            // Lấy Url của trình duyệt
            val capturedUrl: String? = getUrlFromBrowser(parentNodeInfo, browserConfig)
            parentNodeInfo.recycle()

            if (!capturedUrl.isNullOrEmpty() && (packageName != currentBrowserPackageName || capturedUrl != currentUrl)) {
                currentBrowserPackageName = packageName
                currentUrl = capturedUrl

                // Lưu lịch sử duyệt web của trẻ
                DBHelper.insertWebHistory(capturedUrl)

                // Kiểm tra URL bị chặn thì chuyển đến trang trắng
                if (DBHelper.isUrlBlocked(capturedUrl)) {
                    redirectToBlankPage()
                }
            }
        }
    }

    // Lắng nghe khi người dùng có thao tác với ứng dụng trong cài đặt
    private fun handleSettingEvent(accessibilityEvent: AccessibilityEvent) {
        if (accessibilityEvent.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
            val appName = Utils().getMyAppName(applicationContext)
            // Thoát ra khỏi cài đặt khi phát hiện tên của ứng dụng
            if (accessibilityEvent.text.any { it.contains(appName) }) {
                this.performGlobalAction(GLOBAL_ACTION_BACK)
                this.performGlobalAction(GLOBAL_ACTION_HOME)
            }
        }
    }

    // Hàm lấy cấu hình trình duyệt
    private fun getBrowserConfig(packageName: String): BrowserConfig? {
        return BrowserConfig.getSupportedBrowsers().find { it.packageName == packageName }
    }

    // Hàm trích xuất URL từ trình duyệt
    private fun getUrlFromBrowser(
        nodeInfo: AccessibilityNodeInfo, browserConfig: BrowserConfig
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

    /// Hàm hỏi ý kiến của phụ huynh, sử dụng boardcast để gửi thông tin đến flutter
    private fun askParent(packageName: String, appName: String) {
        val intent = Intent()
        // Gửi thông tin cho flutter
        intent.action = AppConstants.ACTION_ASK_PARENT
        intent.putExtra(AppConstants.PACKAGE_NAME, packageName)
        intent.putExtra(AppConstants.APP_NAME, appName)
        sendBroadcast(intent)
    }

    // Kiểm tra còn thời gian được phép sử dụng không
    // TODO: Không dùng nữa
    private fun checkTimeDeviceAllow() {
        coroutineScope.launch {
            val timeUsed = ManageApp().getDeviceUsage(this@AccessibilityService)
            val timeAllow = DBHelper.getTimeAllow(timeUsed)
            val timePeriod = DBHelper.timePeriodValid()
            while (true) {
                // Còn thời gian => không cần hiển thị màn hình chặn
                if (timeAllow.second && timePeriod.second) {
                    if (timeAllow.first > timePeriod.first) {
                        delay(timePeriod.first)
                    } else {
                        delay(timeAllow.first)
                    }
                } else {
                    // Hết thời gian => hiển thị màn hình chặn
                    withContext(Dispatchers.Main) {
                        overlay.showExpiredTimeOverlay(timePeriod.first)
                    }
                    break
                }
            }
        }
    }

    // Hàm lấy tên gói ứng dụng từ Intent
    private fun getPackageNameForIntent(intent: Intent): String? {
        val resolveInfo =
            this.packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return resolveInfo?.activityInfo?.packageName
    }
}
