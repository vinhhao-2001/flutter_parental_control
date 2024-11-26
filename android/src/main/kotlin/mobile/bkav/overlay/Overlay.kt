package mobile.bkav.overlay

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.view.View
import android.view.WindowManager
import io.realm.Realm.getApplicationContext
import mobile.bkav.R
import mobile.bkav.utils.Utils

class Overlay(private val context: Context) {
    private var windowManager: WindowManager? = null
    private var blockView: View? = null

    // Hàm hiển thị overlay mặc định
    fun showOverlay(isBlock: Boolean, onAskParentClick: (() -> Unit?)? = null) {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        var askParentBtn: View? = null
        if (isBlock) {
            blockView =  View.inflate(context, R.layout.activity_block, null)
            askParentBtn = blockView?.findViewById(R.id.askParentBtn)
            askParentBtn?.setOnClickListener {
                // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
            }
        } else {
            blockView = View.inflate(context, R.layout.remove_my_app, null)
        }
        val backButton = blockView?.findViewById<View>(R.id.homeBtn)

        backButton?.setOnClickListener {
            // Xử lý xự kiện đóng màn hình chặn
            (context as AccessibilityService).performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
            //dừng 2s
            Thread.sleep(500)
            Utils().removeBlockScreen(windowManager, blockView)
        }

        askParentBtn?.setOnClickListener {
            // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
            onAskParentClick?.invoke()
            Thread.sleep(500)
            Utils().removeBlockScreen(windowManager, blockView)
        }

        val layoutParams = Utils().getLayoutParams()
        // Thêm view vào màn hình
        windowManager?.addView(blockView, layoutParams)
    }

    // Hàm hiển thị overlay của người dùng tự thêm vào
    fun showOverlay(
        nameOverlayView: String,
        nameBackButtonId: String,
        askParentButtonId: String? = null,
        onAskParentClick: (() -> Unit?)? = null,
    ) {
        // Nếu blockViewName không phải là null, lấy view người dùng tự thêm vào
        blockView = getApplicationContext()?.let { Utils().getView(nameOverlayView, it) }
        if (blockView != null) {
            windowManager =
                context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val backId = getApplicationContext()?.let { Utils().getId(nameBackButtonId, it) }
            val askParentId = getApplicationContext()?.let { askParentButtonId?.let { it1 ->
                Utils().getId(
                    it1, it)
            } }
            val backButton = backId?.let { blockView?.findViewById<View>(it) }
            val askParentBtn = askParentId?.let { blockView?.findViewById<View>(it) }

            backButton?.setOnClickListener {
                (context as AccessibilityService).performGlobalAction(
                    AccessibilityService.GLOBAL_ACTION_HOME
                )
                //dừng 2s
                Thread.sleep(500)
                Utils().removeBlockScreen(windowManager, blockView)
            }
            askParentBtn?.setOnClickListener {
                // Xử lý khi có sự kiện hỏi ý kiến của phụ huynh
                onAskParentClick?.invoke()
                Thread.sleep(500)
                Utils().removeBlockScreen(windowManager, blockView)
            }

            val layoutParams = Utils().getLayoutParams()
            // Thêm view vào màn hình
            windowManager?.addView(blockView, layoutParams)
        }
    }
}
