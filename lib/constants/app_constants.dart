class AppConstants {
  static const String empty = '';
  static const String safeZone = 'Safe Zone';
  static const String done = 'Done';
  static const String update = 'Update';

  /// Method
  static const String methodChannel = 'flutter_parental_control_method';
  static const String eventChannel = 'flutter_parental_control_event';
  static const String deviceMethod = 'getDeviceInfoMethod';
  static const String appUsageMethod = 'getAppUsageInfoMethod';
  static const String blockAppMethod = 'blockAppMethod';
  static const String blockWebMethod = 'blockWebsiteMethod';
  static const String startServiceMethod = 'startServiceMethod';
  static const String permissionMethod = 'permissionMethod';
  static const String scheduleMethod = 'scheduleMonitorMethod';
  static const String limitAppMethod = 'limitAppMethod';
  static const String settingMonitorMethod = 'settingMonitorMethod';
  static const String getWebHistory = 'getWebHistoryMethod';
  static const String askParent = 'askParentMethod';

  /// key data channel
  static const String blockApps = 'blockApps';
  static const String blockWeb = 'blockWebsites';
  static const String typePermission = 'typePermission';

  /// key map
  static const String systemName = 'systemName';
  static const String deviceName = 'deviceName';
  static const String deviceManufacturer = 'deviceManufacturer';
  static const String deviceVersion = 'deviceVersion';
  static const String deviceApiLevel = 'deviceApiLevel';
  static const String deviceBoard = 'deviceBoard';
  static const String deviceHardware = 'deviceHardware';
  static const String deviceDisplay = 'deviceDisplay';
  static const String batteryLevel = 'batteryLevel';
  static const String screenBrightness = 'screenBrightness';
  static const String volume = 'volume';
  static const String deviceId = 'deviceId';

  static const String appIcon = 'appIcon';
  static const String appName = 'appName';
  static const String packageName = 'packageName';
  static const String isInstalled = 'isInstalled';
  static const String usageTime = 'usageTime';

  static const String name = 'name';
  static const String street = 'street';
  static const String locality = 'locality';
  static const String subLocality = 'subLocality';
  static const String subAdminArea = 'subAdminArea';
  static const String adminArea = 'adminArea';
  static const String country = 'country';

  static const String searchQuery = 'searchQuery';
  static const String visitedTime = 'visitedTime';

  /// cài đặt thời gian hạn chế [ios]
  static const String isMonitoring = 'isMonitoring';
  static const String startHour = 'startHour';
  static const String startMinute = 'startMinute';
  static const String endHour = 'endHour';
  static const String endMinute = 'endMinute';

  /// các cài đặt hạn chế [ios]
  static const String requireAutoTime = 'requireAutomaticDateAndTime';
  static const String lockAccounts = 'lockAccounts';
  static const String lockPasscode = 'lockPasscode';
  static const String denySiri = 'denySiri';
  static const String lockAppCellularData = 'lockAppCellularData';
  static const String lockESIM = 'lockESIM';
  static const String denyInAppPurchases = 'denyInAppPurchases';
  static const String maximumRating = 'maximumRating';
  static const String requirePasswordForPurchases =
      'requirePasswordForPurchases';
  static const String denyExplicitContent = 'denyExplicitContent';
  static const String denyMusicService = 'denyMusicService';
  static const String denyBookstoreErotica = 'denyBookstoreErotica';
  static const String maximumMovieRating = 'maximumMovieRating';
  static const String maximumTVShowRating = 'maximumTVShowRating';
  static const String denyMultiplayerGaming = 'denyMultiplayerGaming';
  static const String denyAddingFriends = 'denyAddingFriends';

  /// error
  static const String addressError = 'Unable to get location information';
}