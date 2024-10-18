package mobile.bkav.utils

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import java.io.ByteArrayOutputStream

class Utils {
    // Hàm chuyển đổi drawable thành ByteArray
    fun drawableToByteArray(drawable: Drawable): ByteArray {
        val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                is AdaptiveIconDrawable -> {
                    val width = drawable.intrinsicWidth
                    val height = drawable.intrinsicHeight
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = android.graphics.Canvas(bitmap)
                    drawable.setBounds(0, 0, width, height)
                    drawable.draw(canvas)
                    bitmap
                }

                else -> return byteArrayOf()
            }
        } else {
            when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val width = drawable.intrinsicWidth
                    val height = drawable.intrinsicHeight
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = android.graphics.Canvas(bitmap)
                    drawable.setBounds(0, 0, width, height)
                    drawable.draw(canvas)
                    bitmap
                }
            }
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    // Lấy tên ứng dụng
    fun getApplicationName(context: Context): String {
        val applicationInfo = context.applicationInfo
        val stringId = applicationInfo.labelRes
        return if (stringId == 0) applicationInfo.nonLocalizedLabel.toString()
        else context.getString(stringId)
    }

    // Mở ứng dụng
    fun openApp(context: Context) {
        try {
            val packageName = context.packageName
            val intent = context.packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    // Lấy tên ứng dụng từ tên gói ứng dụng
    fun getAppName(context: Context, packageName: String): String? {
        val packageManager = context.packageManager
        return try {
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
    }


    // Lấy tài nguyên từ ứng dụng
    fun getResource(resourceName: String, context: Context): Int {
        return context.resources.getIdentifier(resourceName, AppConstants.DRAWABLE, context.packageName)
    }

    // Lấy view từ ứng dụng
    fun getView(viewName: String, context: Context): View {
        val layoutId = context.resources.getIdentifier(viewName, AppConstants.LAYOUT, context.packageName)
        return LayoutInflater.from(context).inflate(layoutId, null)
    }

    // Lấy id trong view của ứng dụng
    fun getId(idName: String, context: Context): Int {
        return context.resources.getIdentifier(idName, AppConstants.ID, context.packageName)
    }

    // Tạo cửa sổ hiện thị của overlay
    fun getLayoutParams(): WindowManager.LayoutParams {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
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
    }

    // Loại bỏ cửa sổ hiện thị của overlay
    fun removeBlockScreen(windowManager: WindowManager?, view: View?) {
        if (windowManager != null && view != null) {
            windowManager.removeView(view)
        }
    }
}