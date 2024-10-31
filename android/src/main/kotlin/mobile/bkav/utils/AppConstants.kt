package mobile.bkav.utils

class AppConstants {
    companion object {
        const val EMPTY = ""
        const val COLON = ':'
        const val PACKAGE = "package"
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
        const val GET_APP_DETAIL = "getAppDetailMethod"
        const val BLOCK_APP_METHOD = "blockAppMethod"
        const val BLOCK_WEBSITE_METHOD = "blockWebsiteMethod"
        const val START_SERVICE = "startServiceMethod"
        const val GET_APP_USAGE_INFO = "getAppUsageInfoMethod"
        const val GET_WEB_HISTORY = "getWebHistoryMethod"
        const val REQUEST_PERMISSION = "permissionMethod"
        const val OVERLAY_METHOD = "overlayMethod"
        const val ASK_PARENT_METHOD = "askParentMethod"

        // key
        const val REALM_NAME = "realm-db"
        const val BLOCK_APPS = "blockApps"
        const val BLOCK_WEBSITES = "blockWebsites"
        const val TYPE_PERMISSION = "typePermission"
        const val APP_NAME = "appName"
        const val PACKAGE_NAME = "packageName"
        const val APP_ICON = "appIcon"
        const val IS_INSTALLED = "isInstalled"
        const val TIME_LIMIT = "timeLimit"
        const val USAGE_TIME = "usageTime"
        const val SEARCH_QUERY = "searchQuery"
        const val VISITED_TIME = "visitedTime"
        const val OVERLAY_VIEW = "overlayView";
        const val BACK_BTN = "backButton";
        const val ASK_PARENT_BTN = "askParentBtn";

        // key device info
        const val SYSTEM_NAME = "systemName"
        const val ANDROID = "Android"
        const val DEVICE_NAME = "deviceName"
        const val DEVICE_MANUFACTURER = "deviceManufacturer"
        const val DEVICE_VERSION = "deviceVersion"
        const val DEVICE_API_LEVEL = "deviceApiLevel"
        const val DEVICE_BOARD = "deviceBoard"
        const val DEVICE_HARDWARE = "deviceHardware"
        const val DEVICE_DISPLAY = "deviceDisplay"
        const val BATTERY_LEVEL = "batteryLevel"
        const val SCREEN_BRIGHTNESS = "screenBrightness"
        const val VOLUME = "volume"
        const val DEVICE_ID = "deviceId"

        // key app details
        const val VERSION_CODE = "versionCode"
        const val VERSION_NAME = "versionName"
        const val TIME_INSTALL = "timeInstall"
        const val TIME_UPDATE = "timeUpdate"

        // type view của người dùng
        const val DRAWABLE = "drawable"
        const val LAYOUT = "layout"
        const val ID = "id"

        // error
        const val ERROR_TYPE_PERMISSION = "INVALID_TYPE"
    }
}