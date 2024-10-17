package com.hao.flutter_parental_control.service

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.net.Uri
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import com.hao.flutter_parental_control.db_helper.DBHelper
import com.hao.flutter_parental_control.model.SupportedBrowserConfig
import com.hao.flutter_parental_control.overlay.Overlay
import com.hao.flutter_parental_control.utils.AppConstants
import com.hao.flutter_parental_control.utils.Utils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
// Dịch vụ trợ năng
class AccessibilityService : AccessibilityService() {

    // Khai báo các biến dùng nhiều trong ứng dụng
    private var currentBrowserPackageName: String = AppConstants.EMPTY
    private var currentUrl: String = AppConstants.EMPTY
    private lateinit var channel: MethodChannel

    companion object {
        // Biến tĩnh để lưu FlutterPluginBinding
        private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

        // Phương thức tĩnh để nhận FlutterPluginBinding
        fun setFlutterPluginBinding(binding: FlutterPlugin.FlutterPluginBinding) {
            flutterPluginBinding = binding
        }
    }

    // Xử lý sự kiện Accessibility
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let { accessibilityEvent ->
            val packageName = accessibilityEvent.packageName?.toString() ?: return

            when (accessibilityEvent.eventType) {
                AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED, AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> handleBrowserEvent(
                    accessibilityEvent
                )

                else -> if (packageName == AppConstants.LAUNCHER_PACKAGE) {
                    handleLauncherEvent(accessibilityEvent)
                }
            }
        }
    }

    override fun onInterrupt() {
        // Xử lý khi service bị ngắt
    }

    override fun onServiceConnected() {
        // Xử lý khi service đươc kết nối
        super.onServiceConnected()
        flutterPluginBinding?.let { binding: FlutterPlugin.FlutterPluginBinding ->
            channel = MethodChannel(binding.binaryMessenger, AppConstants.METHOD_CHANNEL)
        }
    }


    private fun handleLauncherEvent(accessibilityEvent: AccessibilityEvent) {
        // Kiểm tra sự kiện khi người dùng nhấn vào ứng dụng
        val contentDescription = accessibilityEvent.contentDescription?.toString() ?: return

        // Kiểm tra sự kiện người dùng muốn xóa ứng dụng
        if (accessibilityEvent.eventType == AccessibilityEvent.TYPE_VIEW_LONG_CLICKED) {
            val appName = Utils().getApplicationName(context = applicationContext)
            if (contentDescription.contains(appName)) {
                val overlay = DBHelper.getOverlayView(false)
                if (overlay != null) {
                    Overlay(this).showOverlay(
                        overlay.overlayView,
                        overlay.nameBackButtonId,
                        overlay.nameAskParentBtnId
                    ) {
                        Utils().openApp(applicationContext)
                        channel.invokeMethod(AppConstants.ASK_PARENT_METHOD)
                    }
                } else {
                    Overlay(this).showOverlay(false)
                }
            }
        }

        // Kiểm tra nếu ứng dụng bị chặn
        if (DBHelper.isAppBlocked(contentDescription)) {
            val overlay = DBHelper.getOverlayView(true)
            if (overlay != null) {
                Overlay(this).showOverlay(
                    overlay.overlayView,
                    overlay.nameBackButtonId,
                    overlay.nameAskParentBtnId
                ) {
                    Utils().openApp(applicationContext)
                    channel.invokeMethod(AppConstants.ASK_PARENT_METHOD)
                }
            } else {
                Overlay(this).showOverlay(false)
            }
        }
    }

    // Hàm xử lý sự kiện khi người dùng mở trình duyệt
    private fun handleBrowserEvent(accessibilityEvent: AccessibilityEvent) {
        // Kiểm tra sự kiện khi người dùng mở trình duyệt
        val parentNodeInfo: AccessibilityNodeInfo = accessibilityEvent.source ?: return
        val packageName: String = accessibilityEvent.packageName?.toString() ?: return
        val browserConfig = getBrowserConfig(packageName) ?: return

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
}