package com.hao.flutter_parental_control.service

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.hao.flutter_parental_control.overlay.BlockOverlay
import com.hao.flutter_parental_control.overlay.RemoveMyAppOverlay
import com.hao.flutter_parental_control.utils.AppConstants

class MyAccessibilityService : AccessibilityService() {

    private var prevApp: String = AppConstants.EMPTY // tên package trình duyệt
    private var prevUrl: String = AppConstants.EMPTY // tên thanh địa chỉ tìm kiếm

    // tên ứng dụng
    private var appName: String = AppConstants.EMPTY // tên ứng dụng parental control
    private var blockedApps: List<String> = mutableListOf()
    private var blockedWebsites: List<String> = mutableListOf()

    // tạo broadcastReceiver để lấy dữ liệu từ flutter
    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val appList = intent?.getStringArrayListExtra("blockApps")
            val webList = intent?.getStringArrayListExtra("blockWebsites")
            if (appList != null) {
                blockedApps = appList
            }
            if (webList != null) {
                blockedWebsites = webList
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val packageName = it.packageName?.toString() ?: return

            when (it.eventType) {
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED, AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                    handleWebViewEvent(it)
                }

                else -> {
                    if (packageName == AppConstants.LAUNCHER_PACKAGE) {
                        handleLauncherEvent(it)
                    }
                }
            }
        }
    }

    override fun onInterrupt() {
        // Xử lý khi service bị ngắt
        unregisterReceiver(broadcastReceiver)
    }

    //
    override fun onServiceConnected() {
        super.onServiceConnected()
        appName = getApplicationName()
        val filter = IntentFilter(AppConstants.BROADCAST_ACCESSIBILITY)
        registerReceiver(broadcastReceiver, filter)
    }

    private fun handleLauncherEvent(event: AccessibilityEvent) {
        val contentDescription = event.contentDescription?.toString() ?: return
        // Xử lý sự kiện khi người muốn xoá ứng dụng quản lý trẻ
        if (event.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED) {
            if (contentDescription.contains(appName)) {
                RemoveMyAppOverlay(this).showRemoveMyAppOverlay()
            }
        }
        // Xử lý sự kiện khi người dùng vào ứng dụng bị chặn
        if (isAppBlocked(contentDescription)) {
            BlockOverlay(this).showBlockScreen()
        }
    }

    // Xử lý sự kiện khi URL được tải lên
    private fun handleWebViewEvent(event: AccessibilityEvent) {
        val parentNodeInfo: AccessibilityNodeInfo =

            event.source ?: return

        val packageName: String = event.packageName?.toString() ?: return
        val browserConfig: SupportedBrowserConfig = getBrowserConfig(packageName) ?: return

        val capturedUrl: String? = captureUrl(parentNodeInfo, browserConfig)
        parentNodeInfo.recycle()

        if (!capturedUrl.isNullOrEmpty() && (packageName != prevApp || capturedUrl != prevUrl)) {
            prevApp = packageName
            prevUrl = capturedUrl
            handleUrlBlocking(capturedUrl)
        }
    }

    // Kiểm tra xem ứng dụng có bị chặn không
    private fun isAppBlocked(appName: String): Boolean {
        return blockedApps.contains(appName)
    }

    // Lấy cấu hình cho trình duyệt dựa trên tên gói ứng dụng
    private fun getBrowserConfig(packageName: String): SupportedBrowserConfig? {
        return SupportedBrowserConfig.get().find { it.packageName == packageName }
    }

    // Lấy URL từ nút tìm kiếm
    private fun captureUrl(info: AccessibilityNodeInfo, config: SupportedBrowserConfig): String? {
        return info.findAccessibilityNodeInfosByViewId(config.addressBarId)
            .firstOrNull()?.text?.toString()
    }

    // Kiểm tra xem URL có bị chặn không
    private fun handleUrlBlocking(capturedUrl: String) {
        if (blockedWebsites.any { capturedUrl.contains(it, ignoreCase = true) }) {
            redirectToBlankPage()
        }
    }

    // Chuyển hướng đến trang trắng
    private fun redirectToBlankPage() {
        val blankPage: Uri = Uri.parse(AppConstants.BLANK_PAGE)
        val intent = Intent(Intent.ACTION_VIEW, blankPage).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        applicationContext.startActivity(intent)
    }

    private fun Context.getApplicationName(): String {
        val applicationInfo = applicationInfo
        val stringId = applicationInfo.labelRes
        return if (stringId == 0) applicationInfo.nonLocalizedLabel.toString() else getString(
            stringId
        )
    }


    class SupportedBrowserConfig(val packageName: String, val addressBarId: String) {
        companion object SupportedBrowsers {
            fun get(): List<SupportedBrowserConfig> {
                return listOf(
                    arrayOf(AppConstants.CHROME_PACKAGE, AppConstants.CHROME_URL),
                    arrayOf(AppConstants.FIREFOX_PACKAGE, AppConstants.FIREFOX_URL),
                    arrayOf(AppConstants.BROWSER_PACKAGE, AppConstants.BROWSER_URL),
                    arrayOf(AppConstants.NATIVE_PACKAGE, AppConstants.NATIVE_URL),
                    arrayOf(AppConstants.DUCK_PACKAGE, AppConstants.DUCK_URL),
                    arrayOf(AppConstants.MICROSOFT_EDGE_PACKAGE, AppConstants.MICROSOFT_EDGE_URL)
                ).map { SupportedBrowserConfig(it[0], it[1]) }
            }
        }
    }
}
