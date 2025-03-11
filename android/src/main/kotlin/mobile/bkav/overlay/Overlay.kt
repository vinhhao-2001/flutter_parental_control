package mobile.bkav.overlay

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityService.GLOBAL_ACTION_HOME
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowManager
import mobile.bkav.R
import mobile.bkav.db_helper.DBHelper
import mobile.bkav.receiver.AdminReceiver
import mobile.bkav.utils.Utils

class Overlay(private val context: Context) {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    // xử lý hiển thị màn hình chặn do hết thời gian sử dụng hoặc xoá ứng dụng
    fun showOverlay(isBlock: Boolean, onAskParentClick: (() -> Unit?)? = null) {
        if (windowManager == null && overlayView == null) {
            windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager?
            val backButton: View?
            val askParentBtn: View?
            val overlay = DBHelper.getOverlayView(isBlock)

            if (overlay != null) {
                // trường hợp overlay do người dùng thêm vào
                overlayView = Utils().getView(context, overlay.overlayView)
                val backId = Utils().getId(context, overlay.backBtnId)
                backButton = overlayView?.findViewById(backId)
                val askParentId = overlay.askParentBtn?.let { Utils().getId(context, it) }
                askParentBtn = askParentId?.let { overlayView?.findViewById(it) }
            } else {
                // trường hợp overlay của plugin
                overlayView = if (isBlock) View.inflate(context, R.layout.open_app_blocked, null)
                else View.inflate(context, R.layout.remove_my_app, null)
                backButton = overlayView?.findViewById(R.id.homeBtn)
                askParentBtn = overlayView?.findViewById(R.id.askParentBtn)
            }

            // Hiển thị màn hình chặn
            val layoutParams = Utils().getLayoutParams()
            windowManager?.addView(overlayView, layoutParams)
            (context as AccessibilityService).performGlobalAction(GLOBAL_ACTION_HOME)

            // Xoá màn hình chặn, đã ở home
            backButton?.setOnClickListener {
                removeBlockScreen()
            }

            // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
            askParentBtn?.setOnClickListener {
                onAskParentClick?.invoke()
                removeBlockScreen()
            }
        }
    }

    // hết thời gian sử dụng màn hình thiết bị
    fun showExpiredTimeOverlay(onAskParentClick: (() -> Unit?)? = null) {
        if (windowManager == null && overlayView == null) {
            windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            overlayView = View.inflate(context, R.layout.overlay_off_device, null)

            val askParentBtn = overlayView?.findViewById<View>(R.id.askParentBtn)
            val offDevice = overlayView?.findViewById<View>(R.id.offDeviceBtn)

            // Hiển thị màn hình chặn
            val layoutParams = Utils().getLayoutParams()
            windowManager?.addView(overlayView, layoutParams)
            (context as AccessibilityService).performGlobalAction(GLOBAL_ACTION_HOME)

            askParentBtn?.setOnClickListener {
                // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
                removeBlockScreen()
                onAskParentClick?.invoke()
            }

            offDevice?.setOnClickListener {
                // Xử lý xự kiện tắt máy
                val devicePolicyManager =
                    context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                val componentName = ComponentName(context, AdminReceiver::class.java)
                if (devicePolicyManager.isAdminActive(componentName)) {
                    devicePolicyManager.lockNow()
                }
            }
        }
    }

    // Loại bỏ cửa sổ hiện thị của overlay
    private fun removeBlockScreen() {
        Handler(Looper.getMainLooper()).postDelayed({
            if (windowManager != null && overlayView != null) {
                windowManager!!.removeView(overlayView)
                windowManager = null
                overlayView = null
            }
        }, 100)
    }
}
