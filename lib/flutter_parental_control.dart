import 'dart:convert';
import 'dart:typed_data';

import 'flutter_parental_control_platform_interface.dart';

class ParentalControl {
  /// Lấy thông tin thiết bị, có sự khác biệt giữa Android và Ios
  static Future<DeviceInfo> getDeviceInfo() async {
    final data = await FlutterParentalControlPlatform.instance.getDeviceInfo();
    return DeviceInfo.fromJson(data);
  }

  /// các phần chỉ dùng được trên [Android]
  /// Lấy thời gian sử dụng trong thiết bị
  static Future<List<AppUsageInfo>> getAppUsageInfo() async {
    final data =
        await FlutterParentalControlPlatform.instance.getAppUsageInfo();

    return data.map((app) => AppUsageInfo.fromMap(app)).toList();
  }

  static Future<void> setListAppBlocked(List<String> listApp) async {
    await FlutterParentalControlPlatform.instance.setListAppBlocked(listApp);
  }

  static Future<void> setListWebBlocked(List<String> listWeb) async {
    await FlutterParentalControlPlatform.instance.setListWebBlocked(listWeb);
  }

  static Future<void> startService() async {
    await FlutterParentalControlPlatform.instance.startService();
  }

  static Stream<AppInstalledInfo> listenAppInstalledInfo() {
    final result = FlutterParentalControlPlatform.instance.listenAppInstalled();
    return result.map((data) => AppInstalledInfo.map(data));
  }

  /// các phần chỉ dùng được trên [Ios]
  /// Kiểm tra quyền kiểm soát của phụ huynh
  static Future<void> checkPermission() async {
    try {
      FlutterParentalControlPlatform.instance.checkParentControlPermission();
    } catch (e) {
      rethrow;
    }
  }

  /// Lập lịch thời gian giám sát thiết bị
  static Future<void> scheduleMonitorSettings(bool isMonitoring, int startHour,
      int startMinute, int endHour, int endMinute) async {
    FlutterParentalControlPlatform.instance.scheduleMonitorSettings(
        isMonitoring, startHour, startMinute, endHour, endMinute);
  }

  /// Mở giao diện chọn danh sách ứng dụng bị giới hạn
  static Future<void> limitedApp() async {
    FlutterParentalControlPlatform.instance.limitedApp();
  }

  /// Cài đặt thiết bị
  static Future<void> settingMonitor({
    bool? requireAutomaticDateAndTime,
    bool? lockAccounts,
    bool? lockPasscode,
    bool? denySiri,
    bool? lockAppCellularData,
    bool? lockESIM,
    bool? denyInAppPurchases,
    int? maximumRating,
    bool? requirePasswordForPurchases,
    bool? denyExplicitContent,
    bool? denyMusicService,
    bool? denyBookstoreErotica,
    int? maximumMovieRating,
    int? maximumTVShowRating,
    bool? denyMultiplayerGaming,
    bool? denyAddingFriends,
  }) async {
    FlutterParentalControlPlatform.instance.settingMonitor(
      requireAutomaticDateAndTime: requireAutomaticDateAndTime,
      lockAccounts: lockAccounts,
      lockPasscode: lockPasscode,
      denySiri: denySiri,
      lockAppCellularData: lockAppCellularData,
      lockESIM: lockESIM,
      denyInAppPurchases: denyInAppPurchases,
      maximumRating: maximumRating,
      requirePasswordForPurchases: requireAutomaticDateAndTime,
      denyExplicitContent: denyExplicitContent,
      denyBookstoreErotica: denyBookstoreErotica,
      maximumMovieRating: maximumMovieRating,
      maximumTVShowRating: maximumTVShowRating,
      denyMultiplayerGaming: denyMultiplayerGaming,
      denyAddingFriends: denyAddingFriends,
    );
  }
}

///Danh sách các [model] của plugin
/// thông tin thiết bị
class DeviceInfo {
  final String? systemName;
  final String? deviceName;
  final String? deviceManufacturer;
  final String? deviceVersion;
  final String? deviceApiLevel;
  final String? deviceBoard;
  final String? deviceHardware;
  final String? deviceDisplay;
  final String? batteryLevel;
  final String? screenBrightness;
  final String? volume;
  final String? deviceId;

  DeviceInfo({
    this.systemName,
    this.deviceName,
    this.deviceManufacturer,
    this.deviceVersion,
    this.deviceApiLevel,
    this.deviceBoard,
    this.deviceHardware,
    this.deviceDisplay,
    this.batteryLevel,
    this.screenBrightness,
    this.volume,
    this.deviceId,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      systemName: json['systemName'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceManufacturer: json['deviceManufacturer'] as String?,
      deviceVersion: json['deviceVersion'] as String?,
      deviceApiLevel: json['deviceApiLevel']?.toString(),
      deviceBoard: json['deviceBoard'] as String?,
      deviceHardware: json['deviceHardware'] as String?,
      deviceDisplay: json['deviceDisplay'] as String?,
      batteryLevel: json['batteryLevel'] as String?,
      screenBrightness: json['screenBrightness'] as String?,
      volume: json['volume'] as String?,
      deviceId: json['deviceId'] as String?,
    );
  }
}

/// thông tin ứng dụng cài đặt hoặc gỡ bỏ
class AppInstalledInfo {
  final bool isInstalled;
  final String packageName;
  final String appName;
  final String appIcon;

  AppInstalledInfo({
    required this.isInstalled,
    required this.packageName,
    required this.appName,
    required this.appIcon,
  });

  factory AppInstalledInfo.map(Map<String, dynamic> map) {
    String iconBase64 =
        base64Encode(Uint8List.fromList(map['appIcon'].cast<int>()));
    return AppInstalledInfo(
      isInstalled: map['isInstalled'],
      packageName: map['packageName'],
      appName: map['appName'],
      appIcon: iconBase64,
    );
  }
}

/// Thông tin thời gian sử dụng các ứng dụng
class AppUsageInfo {
  final String appName;
  final String packageName;
  final String appIcon;
  final int usageTime;

  AppUsageInfo({
    required this.appName,
    required this.packageName,
    required this.appIcon,
    required this.usageTime,
  });

  factory AppUsageInfo.fromMap(Map<String, dynamic> map) {
    String iconBase64 =
        base64Encode(Uint8List.fromList(map['appIcon'].cast<int>()));
    return AppUsageInfo(
      appName: map['appName'],
      packageName: map['packageName'],
      appIcon: iconBase64,
      usageTime: map['usageTime'],
    );
  }
}
