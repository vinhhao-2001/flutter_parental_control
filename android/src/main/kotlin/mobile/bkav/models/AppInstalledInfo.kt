package mobile.bkav.models

import mobile.bkav.utils.AppConstants


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

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as AppInstalledInfo

        return appIcon.contentEquals(other.appIcon)
    }

    override fun hashCode(): Int {
        return appIcon.contentHashCode()
    }
}

