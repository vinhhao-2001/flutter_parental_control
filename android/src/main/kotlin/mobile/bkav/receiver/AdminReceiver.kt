package mobile.bkav.receiver

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        // Xử lý khi thiết bị được cài đặt thành công
        Log.d("TAG", "Device Admin Enabled")
    }
    override fun onDisabled(context: Context, intent: Intent) {
        // Xử lý khi thiết bị bị tắt
        Log.d("TAG", "Device Admin Disabled")
    }
}