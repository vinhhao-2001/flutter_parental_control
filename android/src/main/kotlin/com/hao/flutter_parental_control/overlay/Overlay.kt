package com.hao.flutter_parental_control.overlay

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.view.View
import android.view.WindowManager
import com.hao.flutter_parental_control.R
import com.hao.flutter_parental_control.utils.Utils
import io.realm.Realm.getApplicationContext

class Overlay(private val context: Context) {
    private var windowManager: WindowManager? = null
    private var blockView: View? = null

    fun showOverlay(isBlock: Boolean) {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        blockView = if (isBlock) {
            View.inflate(context, R.layout.activity_block, null)
        } else {
            View.inflate(context, R.layout.remove_my_app, null)
        }

        val backButton = blockView?.findViewById<View>(R.id.homeBtn)

        backButton?.setOnClickListener {
            (context as AccessibilityService).performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
            //dừng 2s
            Thread.sleep(500)
            Utils().removeBlockScreen(windowManager, blockView)
        }
        val layoutParams = Utils().getLayoutParams()
        // Thêm view vào màn hình
        windowManager?.addView(blockView, layoutParams)
    }

    fun showOverlay(
        nameBlockView: String,
        nameBackButton: String,
        askParentButton: String? = null,
        onAskParentClick: (() -> Unit?)? = null,
    ) {
        // Nếu blockViewName không phải là null, lấy view người dùng tự thêm vào
        blockView = getApplicationContext()?.let { Utils().getView(nameBlockView, it) }
        if (blockView != null) {
            windowManager =
                context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
            val backId = getApplicationContext()?.let { Utils().getId(nameBackButton, it) }
            val askParentId = getApplicationContext()?.let { askParentButton?.let { it1 ->
                Utils().getId(
                    it1, it)
            } }
            val backButton = blockView?.findViewById<View>(backId!!)
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
            }

            val layoutParams = Utils().getLayoutParams()
            // Thêm view vào màn hình
            windowManager?.addView(blockView, layoutParams)
        }
    }
}
