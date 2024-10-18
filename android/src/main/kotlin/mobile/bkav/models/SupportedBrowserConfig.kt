package mobile.bkav.models

import mobile.bkav.utils.AppConstants


class SupportedBrowserConfig(val packageName: String, val addressBarId: String) {
    // Cấu hình danh sách các trình duyệt được hỗ trợ
    companion object {
        fun getSupportedBrowsers(): List<SupportedBrowserConfig> {
            return listOf(
                arrayOf(AppConstants.CHROME_PACKAGE, AppConstants.CHROME_URL),
                arrayOf(AppConstants.FIREFOX_PACKAGE, AppConstants.FIREFOX_URL),
                arrayOf(AppConstants.BROWSER_PACKAGE, AppConstants.BROWSER_URL),
                arrayOf(AppConstants.NATIVE_PACKAGE, AppConstants.NATIVE_URL),
                arrayOf(AppConstants.DUCK_PACKAGE, AppConstants.DUCK_URL),
                arrayOf(AppConstants.MICROSOFT_EDGE_PACKAGE, AppConstants.MICROSOFT_EDGE_URL)
            ).map { SupportedBrowserConfig(it[0], it[1]) }
        }
    }
}