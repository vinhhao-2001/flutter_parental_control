class AppConstants{
    
    public static let EMPTY = ""
    // method
    public static let METHOD_CHANNEL = "flutter_parental_control_method"
    public static let GET_DEVICE_INFO = "getDeviceInfoMethod"
    public static let GET_LOCATION = "getLocationMethod"
    public static let CHECK_PERMISSION = "permissionMethod"
    public static let SCHEDULE_MONITOR = "scheduleMonitorMethod"
    public static let LIMITED_APP = "limitAppMethod"
    public static let SETTING_MONITOR = "settingMonitorMethod"
    
    // key data
    // device info
    public static let APPLE = "Apple"
    public static let UNKNOWN = "Unknown"
    public static let SYSTEM_NAME = "systemName"
    public static let DEVICE_NAME = "deviceName"
    public static let DEVICE_MANUFACTURER = "deviceManufacturer"
    public static let SYSTEM_VERSION = "systemVersion"
    public static let DEVICE_API_LEVEL = "deviceApiLevel"
    public static let BATTERY_LEVEL = "batteryLevel"
    public static let SCREEN_BRIGHTNESS = "screenBrightness"
    public static let VOLUME = "volume"
    public static let MODEL_NAME = "modelName"
    public static let LOCALIZED_MODEL = "localizedModel"
    public static let DEVICE_ID = "deviceId"
    // key schedule monitor
    public static let DAILY = "daily"
    public static let WEEKLY = "weekly"
    public static let IS_MONITORING = "isMonitoring"
    public static let START_HOUR = "startHour"
    public static let START_MINUTE = "startMinute"
    public static let END_HOUR = "endHour"
    public static let END_MINUTE = "endMinute"
    // key monitor setting
    public static let REQUIRE_AUTO_DATE = "requireAutomaticDateAndTime"
    public static let LOCK_ACCOUNTS = "lockAccounts"
    public static let LOCK_PASSCODE = "lockPasscode"
    public static let DENY_SIRI = "denySiri"
    public static let LOCK_APP_CELLULAR_DATA = "lockAppCellularData"
    public static let LOCK_E_SIM = "lockESIM"
    public static let DENY_IN_APP_PURCHASES = "denyInAppPurchases"
    public static let MAXIMUM_RATING = "maximumRating"
    public static let REQUIRE_PASSWORD_FOR_PURCHASES = "requirePasswordForPurchases"
    public static let DENY_EXPLICIT_CONTENT = "denyExplicitContent"
    public static let DENY_MUSIC_SERVICE = "denyMusicService"
    public static let DENY_BOOKSTORE_EROTICA = "denyBookstoreErotica"
    public static let MAXIMUM_MOVIE_RATING = "maximumMovieRating"
    public static let MAXIMUM_TV_SHOW_RATING = "maximumTVShowRating"
    public static let DENY_MULTIPLAYER_GAMING = "denyMultiplayerGaming"
    public static let DENY_ADDING_FRIENDS = "denyAddingFriends"
    
    // error code
    public static let UNAVAILABLE = "UNAVAILABLE"
    public static let AUTH_NOT_DETERMINED = "AUTH_NOT_DETERMINED"
    public static let AUTH_DENIED = "AUTH_DENIED"
    public static let AUTH_APPROVED = "AUTH_APPROVED"
    public static let UNKNOWN_AUTH_STATUS = "UNKNOWN_AUTH_STATUS"
    public static let NO_ICLOUD_ACCOUNT = "NO_ICLOUD_ACCOUNT"
    public static let INVALID_ACCOUNT_TYPE = "INVALID_ACCOUNT_TYPE"
    public static let AUTHORIZATION_CANCELED = "AUTHORIZATION_CANCELED"
    public static let UNKNOWN_ERROR = "UNKNOWN_ERROR"
    public static let SCHEDULE_MONITOR_ERROR = "SCHEDULE_MONITOR_ERROR"
    
    // error
    public static let CONTROLLER_ERROR = "FlutterViewController not available"
    public static let SCHEDULE_ERROR =  "Lỗi khi lên lịch giám sát"
}
