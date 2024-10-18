package com.hao.flutter_parental_control.model

import com.hao.flutter_parental_control.utils.AppConstants

// Thông tin ứng dụng được cài đặt hoặc gỡ bỏ
data class AppInstalledInfo(
    val isInstalled: Boolean,
    val packageName: String,
    val appName: String,
    val appIcon: ByteArray
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            AppConstants.IS_INSTALLED to isInstalled,
            AppConstants.PACKAGE_NAME to packageName,
            AppConstants.APP_NAME to appName,
            AppConstants.APP_ICON to appIcon
        )
    }

    // các hàm override tự sinh
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as AppInstalledInfo

        if (isInstalled != other.isInstalled) return false
        if (packageName != other.packageName) return false
        if (appName != other.appName) return false
        if (!appIcon.contentEquals(other.appIcon)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = isInstalled.hashCode()
        result = 31 * result + packageName.hashCode()
        result = 31 * result + appName.hashCode()
        result = 31 * result + appIcon.contentHashCode()
        return result
    }
}

