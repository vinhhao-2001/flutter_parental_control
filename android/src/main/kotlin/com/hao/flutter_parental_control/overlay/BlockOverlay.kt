package com.hao.flutter_parental_control.overlay

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.View
import android.view.WindowManager
import com.hao.flutter_parental_control.R

class BlockOverlay(private val context: Context) {
    private var windowManager: WindowManager? = null
    private var blockView: View? = null

    fun showBlockScreen() {
        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

        blockView = View.inflate(context, R.layout.activity_block, null)

        val backButton = blockView?.findViewById<View>(R.id.backBtn)

        backButton?.setOnClickListener {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                (context as AccessibilityService).performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
            }
            //dừng 2s
            Thread.sleep(500)
            removeBlockScreen()
        }

        val layoutParams = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            )
        } else {
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.TYPE_APPLICATION,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                PixelFormat.TRANSLUCENT
            )
        }


        // Thêm view vào màn hình
        windowManager?.addView(blockView, layoutParams)
    }

    // Xóa view khỏi màn hình
    private fun removeBlockScreen() {
        if (blockView != null) {
            windowManager?.removeView(blockView)
            blockView = null
        }
    }
}
