package mobile.bkav.overlay

import android.accessibilityservice.AccessibilityService
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.view.View
import android.view.WindowManager
import io.realm.Realm.getApplicationContext
import mobile.bkav.R
import mobile.bkav.db_helper.DBHelper
import mobile.bkav.receiver.AdminReceiver
import mobile.bkav.utils.Utils

class Overlay(private val context: Context) {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null

    // TODO: xử lý hiển thị màn hình chặn do hết thời gian sử dụng hoặc xoá ứng dụng
    fun showOverlay(isBlock: Boolean, onAskParentClick: (() -> Unit?)? = null) {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager?
        val backButton: View?
        val askParentBtn: View?
        val overlay = DBHelper.getOverlayView(isBlock)
        if (overlay != null) {
            // trường hợp có overlay trong db
            overlayView = Utils().getView(context, overlay.overlayView)
            val backId = Utils().getId(context, overlay.backBtnId)
            backButton = overlayView?.findViewById(backId)
            val askParentId = overlay.askParentBtn?.let { Utils().getId(context, it) }
            askParentBtn = askParentId?.let { overlayView?.findViewById(it) }
        } else {
            // trường hợp không có overlay trong db
            overlayView = if (isBlock) View.inflate(context, R.layout.open_app_blocked, null)
            else View.inflate(context, R.layout.remove_my_app, null)
            backButton = overlayView?.findViewById(R.id.homeBtn)
            askParentBtn = overlayView?.findViewById(R.id.askParentBtn)
        }
        backButton?.setOnClickListener {
            Utils().removeBlockScreen(context, windowManager, overlayView)
        }
        askParentBtn?.setOnClickListener {
            Utils().removeBlockScreen(context, windowManager, overlayView)
            // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
            onAskParentClick?.invoke()
        }
    }

//    // Hàm hiển thị overlay mặc định
//    fun showOverlay(isBlock: Boolean, onAskParentClick: (() -> Unit?)? = null) {
//        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
//        var askParentBtn: View? = null
//        if (isBlock) {
//            overlayView = View.inflate(context, R.layout.open_app_blocked, null)
//            askParentBtn = overlayView?.findViewById(R.id.askParentBtn)
//            askParentBtn?.setOnClickListener {
//                Utils().removeBlockScreen(context, windowManager, overlayView)
//                // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
//                onAskParentClick?.invoke()
//            }
//        } else {
//            overlayView = View.inflate(context, R.layout.remove_my_app, null)
//        }
//        val backButton = overlayView?.findViewById<View>(R.id.homeBtn)
//
//        backButton?.setOnClickListener {
//            Utils().removeBlockScreen(context, windowManager, overlayView)
//        }
//
//        askParentBtn?.setOnClickListener {
//            // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
//            onAskParentClick?.invoke()
//            Utils().removeBlockScreen(context, windowManager, overlayView, true)
//        }
//
//        val layoutParams = Utils().getLayoutParams()
//        // Thêm view vào màn hình
//        windowManager?.addView(overlayView, layoutParams)
//    }

    // Hàm hiển thị overlay của người dùng tự thêm vào
    fun showOverlay(
        nameOverlayView: String,
        nameBackButtonId: String,
        askParentButtonId: String? = null,
        onAskParentClick: (() -> Unit?)? = null,
    ) {
        // Nếu blockViewName không phải là null, lấy view người dùng tự thêm vào
        overlayView = getApplicationContext()?.let { Utils().getView(it, nameOverlayView) }
        if (overlayView != null) {
            windowManager =
                context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val backId = getApplicationContext()?.let { Utils().getId(it, nameBackButtonId) }
            val askParentId = getApplicationContext()?.let {
                askParentButtonId?.let { it1 ->
                    Utils().getId(
                        it, it1
                    )
                }
            }

            val backButton = backId?.let { overlayView?.findViewById<View>(it) }
            val askParentBtn = askParentId?.let { overlayView?.findViewById<View>(it) }

            backButton?.setOnClickListener {
                Utils().removeBlockScreen(context, windowManager, overlayView)
            }
            askParentBtn?.setOnClickListener {
                // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
                Utils().removeBlockScreen(context, windowManager, overlayView, true)
                onAskParentClick?.invoke()
            }

            val layoutParams = Utils().getLayoutParams()
            // Thêm view vào màn hình
            windowManager?.addView(overlayView, layoutParams)
        }
    }

    // hết thời gian sử dụng màn hình thiết bị
    fun showExpiredTimeOverlay(onAskParentClick: (() -> Unit?)? = null) {
        if (windowManager == null && overlayView == null) {
            windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            overlayView = View.inflate(context, R.layout.overlay_off_device, null)

            val askParentBtn = overlayView?.findViewById<View>(R.id.askParentBtn)
            askParentBtn?.setOnClickListener {
                // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
                onAskParentClick?.invoke()
                Utils().removeBlockScreen(context, windowManager, overlayView)
                overlayView = null
                windowManager = null
            }

            val offDevice = overlayView?.findViewById<View>(R.id.offDeviceBtn)
            offDevice?.setOnClickListener {
                // Xử lý xự kiện tắt máy
                (context as AccessibilityService).performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
                val devicePolicyManager =
                    context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                val componentName = ComponentName(context, AdminReceiver::class.java)
                if (devicePolicyManager.isAdminActive(componentName)) {
                    devicePolicyManager.lockNow()
                }
            }
            val layoutParams = Utils().getLayoutParams()
            // Thêm view vào màn hình
            windowManager?.addView(overlayView, layoutParams)
        }
    }
}
