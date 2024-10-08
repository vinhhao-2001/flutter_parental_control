package com.hao.flutter_parental_control.utils

class AppConstants {
    companion object {

        const val EMPTY = ""
        const val PACKAGE = "package"
        const val BROADCAST_ACCESSIBILITY = "broadcast_accessibility"
        const val LAUNCHER_PACKAGE = "com.google.android.apps.nexuslauncher"

        // trình duyệt
        const val BLANK_PAGE = "about:blank"
        const val CHROME_PACKAGE = "com.android.chrome"
        const val FIREFOX_PACKAGE = "org.mozilla.firefox"
        const val BROWSER_PACKAGE = "com.android.browser"
        const val NATIVE_PACKAGE = "com.opera.mini.native"
        const val DUCK_PACKAGE = "com.duckduckgo.mobile.android"
        const val MICROSOFT_EDGE_PACKAGE = "com.microsoft.emmx"

        const val CHROME_URL = "com.android.chrome:id/url_bar"
        const val FIREFOX_URL = "org.mozilla.firefox:id/mozac_browser_toolbar_url_view"
        const val BROWSER_URL = "com.opera.browser:id/url_field"
        const val NATIVE_URL = "com.opera.mini.native:id/url_field"
        const val DUCK_URL = "com.duckduckgo.mobile.android:id/omnibarTextInput"
        const val MICROSOFT_EDGE_URL = "com.microsoft.emmx:id/url_bar"

        // channel
        const val METHOD_CHANNEL = "flutter_parental_control_method"
        const val EVENT_CHANNEL = "flutter_parental_control_event"
        const val GET_DEVICE_INFO = "getDeviceInfoMethod"
        const val BLOCK_APP_METHOD = "blockAppMethod"
        const val BLOCK_WEBSITE_METHOD = "blockWebsiteMethod"
        const val START_SERVICE = "startServiceMethod"
        const val GET_APP_USAGE_INFO = "getAppUsageInfoMethod"



    }
}