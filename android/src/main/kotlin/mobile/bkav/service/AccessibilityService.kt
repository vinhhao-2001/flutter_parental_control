package mobile.bkav.service

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.net.Uri
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mobile.bkav.db_helper.DBHelper
import mobile.bkav.manager.ManagerApp
import mobile.bkav.models.SupportedBrowserConfig
import mobile.bkav.overlay.Overlay
import mobile.bkav.utils.AppConstants
import mobile.bkav.utils.Utils


// Dịch vụ trợ năng
class AccessibilityService : AccessibilityService() {

    // Khai báo các biến dùng nhiều trong ứng dụng
    private var currentBrowserPackageName: String = AppConstants.EMPTY
    private var currentUrl: String = AppConstants.EMPTY

    private val coroutineScope = CoroutineScope(Dispatchers.IO)

    override fun onServiceConnected() {
        // Xử lý khi service đươc kết nối
        super.onServiceConnected()
        // Kiểm tra còn được phép sử dụng không
        coroutineScope.launch {
            val timeUsed = ManagerApp().getDeviceUsage(this@AccessibilityService)
            val timeAllow = DBHelper.getTimeAllow()
            while (true) {
                if (timeAllow != null) {
                    // Đã cài đặt thời gian
                    val periodValid = DBHelper.isTimeAllowedValid()
                    if (timeAllow * 60000 > timeUsed && periodValid) {
                        // Chờ đến thời gian mới
                        delay(timeAllow * 60000 - timeUsed)
                    } else {
                        withContext(Dispatchers.Main) {
                            Overlay(this@AccessibilityService).showExpiredTimeOverlay()
                        }
                        break
                    }
                } else {
                    break
                }
            }
        }
    }

    override fun onInterrupt() {
        // Xử lý khi service bị ngắt
    }

    // Xử lý sự kiện Accessibility
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let { accessibilityEvent ->
            val packageName = accessibilityEvent.packageName?.toString() ?: return
            when (accessibilityEvent.eventType) {
                // Giám sát sự kiện trình duyệt
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED, AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> handleBrowserEvent(
                    accessibilityEvent
                )
                // Sự kiện khi ở trong màn hình chính
                else -> if (packageName == AppConstants.LAUNCHER_PACKAGE) {
                    handleLauncherEvent(accessibilityEvent)
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
            val appName = Utils().getApplicationName(context = applicationContext)
            if (contentDescription.contains(appName)) {
                Overlay(this).showOverlay(false) {
                    askParent(packageName, appName)
                }
            }
        }

        // Kiểm tra nếu ứng dụng bị chặn
        val packageName = DBHelper.isAppBlocked(context = applicationContext, contentDescription)
        if (packageName != null) {
            // Hiển thị màn hình chặn
            Overlay(this).showOverlay(false) {
                askParent(packageName, appName = contentDescription)
            }
        }
    }

    // Hàm xử lý sự kiện khi người dùng mở trình duyệt
    @Suppress("DEPRECATION")
    private fun handleBrowserEvent(accessibilityEvent: AccessibilityEvent) {
        // Kiểm tra sự kiện khi người dùng mở trình duyệt
        val parentNodeInfo: AccessibilityNodeInfo = accessibilityEvent.source ?: return
        val packageName: String = accessibilityEvent.packageName?.toString() ?: return
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
}
